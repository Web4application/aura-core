#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *dialog, *content, *label, *entry;

    dialog = gtk_dialog_new_with_buttons(
        "OpenSSH Authentication Required",
        NULL,
        GTK_DIALOG_MODAL,
        "_Cancel", GTK_RESPONSE_CANCEL,
        "_Unlock", GTK_RESPONSE_OK,
        NULL
    );

    content = gtk_dialog_get_content_area(GTK_DIALOG(dialog));

    label = gtk_label_new("Enter your SSH key passphrase:");
    gtk_label_set_xalign(GTK_LABEL(label), 0.0);

    entry = gtk_entry_new();
    gtk_entry_set_visibility(GTK_ENTRY(entry), FALSE);
    gtk_entry_set_invisible_char(GTK_ENTRY(entry), '•');
    gtk_entry_set_activates_default(GTK_ENTRY(entry), TRUE);

    gtk_box_append(GTK_BOX(content), label);
    gtk_box_append(GTK_BOX(content), entry);

    gtk_dialog_set_default_response(GTK_DIALOG(dialog), GTK_RESPONSE_OK);
    gtk_window_set_application(GTK_WINDOW(dialog), app);
    gtk_widget_show(dialog);

    if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_OK) {
        const char *pass = gtk_entry_get_text(GTK_ENTRY(entry));
        g_print("%s", pass);
    }

    gtk_window_destroy(GTK_WINDOW(dialog));
}

int main(int argc, char **argv) {
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.unkpg.askpass", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}
