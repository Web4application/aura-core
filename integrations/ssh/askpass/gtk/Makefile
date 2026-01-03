CC=gcc
CFLAGS=`pkg-config --cflags gtk4`
LDFLAGS=`pkg-config --libs gtk4`
TARGET=unkpg-gtk-askpass

all:
	$(CC) src/main.c -o $(TARGET) $(CFLAGS) $(LDFLAGS)

install:
	install -Dm755 $(TARGET) /usr/local/bin/$(TARGET)

clean:
	rm -f $(TARGET)
