#include <gtk/gtk.h>

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);

    GtkWidget *dialog = gtk_dialog_new_with_buttons(
        "OpenSSH Authentication Required",
        NULL,
        GTK_DIALOG_MODAL,
        "_Cancel", GTK_RESPONSE_CANCEL,
        "_Unlock", GTK_RESPONSE_OK,
        NULL
    );

    GtkWidget *content = gtk_dialog_get_content_area(GTK_DIALOG(dialog));

    GtkWidget *label = gtk_label_new("Enter your SSH key passphrase:");
    GtkWidget *entry = gtk_entry_new();
    gtk_entry_set_visibility(GTK_ENTRY(entry), FALSE);
    gtk_entry_set_invisible_char(GTK_ENTRY(entry), '•');

    gtk_box_pack_start(GTK_BOX(content), label, FALSE, FALSE, 8);
    gtk_box_pack_start(GTK_BOX(content), entry, FALSE, FALSE, 8);

    gtk_widget_show_all(dialog);

    if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_OK) {
        const char *pass = gtk_entry_get_text(GTK_ENTRY(entry));
        g_print("%s", pass);
    }

    gtk_widget_destroy(dialog);
    return 0;
}
