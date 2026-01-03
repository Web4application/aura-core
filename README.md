```cpp
unkpg/
├── core/
│   ├── runtime/
│   └── security/
│
├── integrations/
│   ├── ssh/
│   │   ├── askpass/
│   │   │   ├── gtk/
│   │   │   │   ├── main.c
│   │   │   │   └── Makefile
│   │   │   ├── legacy-x11/
│   │   │   │   └── SshAskpass.ad
│   │   │   └── selector.sh
│   │   └── README.md
│
├── packaging/
└── README.md
```
## Security Integrations

unkpg includes optional, modular security integrations such as a modern
SSH askpass helper. These components are disabled by default and designed
to improve GUI authentication flows without altering OpenSSH behavior.
