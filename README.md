
# trend_tools

A collection of handy scripts to support Trend Micro integrations, automations, and platform setup. This toolbox is designed for internal or customer-facing scenarios where quick deployment, environment configuration, or component installation is needed.

## 🔧 Tools Included

| Script                  | Description |
|-------------------------|-------------|
| `install_v1fs_sdk_cli.sh` | Installs the Vision One File Storage (V1FS) SDK CLI for managing file storage security features. |
| `install_tmas.sh`         | Automates the setup of Trend Micro Artifact Scan (TMAS) including CLI dependencies and environment configuration. |
| `other_tools.sh`          | Installs a suite of essential tools used in cloud-native and containerized environments (e.g., AWS CLI, kubectl, Docker, eksctl, Helm). |

## 📦 Usage

Make sure the scripts are executable:

```bash
chmod +x install_v1fs_sdk_cli.sh install_tmas.sh other_tools.sh
```

Run the script of your choice:

```bash
./install_v1fs_sdk_cli.sh
```

You may be prompted for sudo access during installation.

## 📚 Tools Installed by `other_tools.sh`

This helper script installs the following:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [eksctl](https://eksctl.io/) – for Amazon EKS cluster management
- [Docker](https://www.docker.com/) – container runtime engine
- [kubectl](https://kubernetes.io/docs/tasks/tools/) – Kubernetes command-line tool
- [Helm](https://helm.sh/) – Kubernetes package manager

These tools are essential for working with cloud and container environments.

## 🛠 Requirements

- Linux environment (Tested on Ubuntu 20.04+)
- `curl`, `unzip`, and basic CLI tools
- Internet access to download dependencies

## 📝 Notes

- These tools are meant for quick prototyping and setup. Review scripts before running them in production environments.
- Some scripts may require API keys or credentials – ensure you follow your internal security guidelines.

## 📫 Contributions

Pull requests are welcome for additional Trend Micro integrations, fixes, or new helper scripts.
