#include "my_application.h"
#include <gtk/gtk.h>

int main(int argc, char** argv) {
  // Initialize GTK first
  gtk_init(&argc, &argv);

  g_autoptr(MyApplication) app = my_application_new();
  int status = g_application_run(G_APPLICATION(app), argc, argv);

  return status;
}
