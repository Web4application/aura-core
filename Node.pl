:- encoding(utf8).

/* =========================
   Prolog HTTP Logic Node
   ========================= */

:- module(node, [nodeinfo/1]).

/* -------- Libraries -------- */
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(settings)).
:- use_module(library(apply)).
:- use_module(library(sandbox)).
:- use_module(library(debug)).
:- use_module(library(random)).

/* -------- App Modules -------- */
:- use_module(rpc).
:- use_module(src).
:- use_module(src:rpc).

/* -------- State -------- */
:- dynamic cache/3.   % cache(QueryID, Offset, ThreadId)

/* -------- Settings -------- */
:- setting(cache_maxsize, integer, 100, 'Max cache entries').
:- setting(timeout, number, 1, 'Query timeout (seconds)').

/* -------- Init -------- */
:- initialization(flag(cache_size, _, 0)).
:- initialization(server(localhost, 3001)).

/* -------- HTTP Routes -------- */
:- http_handler(/, http_reply_file('shell.html', []), []).
:- http_handler(root(src), http_reply_file('src.pl', []), []).
:- http_handler(root(ask), http_ask, [spawn([])]).

/* =========================
   HTTP Endpoint
   ========================= */

http_ask(Request) :-
    http_parameters(Request,
        [ query(QueryAtom, []),
          offset(Offset, [integer, default(0)]),
          limit(Limit, [integer, default(1)]),
          format(Format, [atom, default(json)])
        ]),
    catch(
        read_term_from_atom(QueryAtom, Query, [variable_names(Bindings)]),
        Error,
        true
    ),
    (   var(Error)
    ->  fix_template(Format, Query, Bindings, Template),
        find_answer(Template, Query, Offset, Limit, Answer),
        output_result(Format, Answer)
    ;   output_result(Format, error(Error))
    ).

/* =========================
   Template Handling
   ========================= */

fix_template(Format, _, Bindings, Template) :-
    json_lang(Format),
    !,
    exclude(anon, Bindings, Named),
    dict_create(Template, json, Named).
fix_template(_, Template, _, Template).

anon(Name=_) :-
    sub_atom(Name, 0, _, _, '_'),
    sub_atom(Name, 1, 1, _, C),
    char_type(C, prolog_var_start).

json_lang(json).
json_lang(Format) :- sub_atom(Format, 0, _, _, 'json-').

/* =========================
   Output
   ========================= */

output_result(prolog, Answer) :-
    format('Content-type: text/plain; charset=UTF-8~n~n'),
    write_term(Answer, [
        quoted(true), ignore_ops(true),
        fullstop(true), nl(true)
    ]).

output_result(json, Answer) :-
    answer_to_json(Answer, JSON),
    reply_json(JSON).

answer_to_json(success(Bindings, More),
    json{type:success, data:JSONBindings, more:More}) :-
    maplist(bindings_to_json_strings, Bindings, JSONBindings).
answer_to_json(failure, json{type:failure}).
answer_to_json(error(E), json{type:error, data:Msg}) :-
    message_to_string(E, Msg).

bindings_to_json_strings(Dict, Out) :-
    dict_pairs(Dict, Tag, Pairs),
    maplist(term_string_value, Pairs, OutPairs),
    dict_pairs(Out, Tag, OutPairs).

term_string_value(K-V, K-S) :-
    with_output_to(string(S), write_term(V,[quoted(true)])).

/* =========================
   Query Engine
   ========================= */

find_answer(Template, Query, Offset, Limit, Answer) :-
    thread_self(Self),
    query_id(Query, QID),
    (   retract(cache(QID, Offset, Pid))
    ->  next(Pid, Self, Limit)
    ;   ask(Template, Query, Offset, Limit, Pid)
    ),
    wait_for_answer(Self, Pid, QID, Offset, Limit, Answer).

query_id(Query, Hash) :-
    copy_term(Query, Q),
    numbervars(Q, 0, _),
    term_hash(Q, Hash).

ask(Template, Query, Offset, Limit, Pid) :-
    pengine_uuid(Pid),
    thread_self(Parent),
    thread_create(
        query_thread(Template, Query, Offset, Limit, Parent),
        _,
        [alias(Pid), at_exit(done)]
    ),
    flag(cache_size, N, N+1).

pengine_uuid(Id) :-
    random_between(0, 1<<128, N),
    atom_number(Id, N).

query_thread(Template, Query, Offset, Limit, Parent) :-
    catch(
        guarded_query(Template, Query, Offset, Limit, Parent),
        E,
        thread_send_message(Parent, error(E))
    ).

guarded_query(Template, Query, Offset, Limit, Parent) :-
    State = count(Limit),
    safe_goal(Query),
    (   call_cleanup(
            findnsols(State, Template, offset(Offset, src:Query), Sols),
            Det=true
        ),
        Sols \== []
    ->  thread_send_message(Parent, success(Sols, Det == true))
    ;   thread_send_message(Parent, failure)
    ).

done :-
    thread_self(Me),
    retractall(cache(_, _, Me)),
    flag(cache_size, N, N-1),
    thread_detach(Me).

next(Pid, Parent, Limit) :-
    thread_send_message(Pid, next(Parent, Limit)).

wait_for_answer(Self, Pid, QID, Offset, Limit, Answer) :-
    setting(timeout, Timeout),
    (   thread_get_message(Self, Answer, [timeout(Timeout)])
    ->  ( Answer = success(_, true)
        ->  NewOffset is Offset + Limit,
            assertz(cache(QID, NewOffset, Pid))
        ;   true
        )
    ;   Answer = error(error(timeout_exceeded, Timeout)),
        kill_thread(Pid)
    ).

kill_thread(Pid) :-
    catch(thread_detach(Pid), _, true),
    catch(thread_signal(Pid, thread_exit(Pid)), _, true).

/* =========================
   Sandbox
   ========================= */

:- multifile sandbox:safe_primitive/1.
sandbox:safe_primitive(rpc:rpc(_,_,_)).
sandbox:safe_primitive(system:get_flag(_,_)).

/* =========================
   Node Info
   ========================= */

nodeinfo([
    profile(isobase),
    timeout(T),
    cache_maxsize(M),
    cache_cursize(S)
]) :-
    setting(timeout, T),
    setting(cache_maxsize, M),
    get_flag(cache_size, S).

/* =========================
   Server
   ========================= */

server(Host, Port) :-
    http_server(http_dispatch,
        [ port(Host:Port),
          workers(24)
        ]).
