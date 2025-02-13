#!/bin/sh

VERSION="0.1.0"
UPDATE=0

get_system_info() {
    SYSARCH="$(uname -m)"
    SYSTYPE="$(uname -s)"
    case "$SYSARCH" in
        x86_64)
            SYSARCH="amd64"
            ;;
        aarch64)
            SYSARCH="arm64"
            ;;
        i386)
            SYSARCH="386"
            ;;
    esac
    case "$SYSTYPE" in
        Linux)
            SYSTYPE="linux"
            ;;
        Darwin)
            SYSTYPE="darwin"
            ;;
        *)
            printf "Unsupported system type: %s\n" "$SYSTYPE"
            exit 1
            ;;
    esac
}

download() {
    printf "* Downloading OpenSCA-cli from: %s\n" "$download_url"
    curl --silent -L "$download_url" -o opensca-cli.tar.gz
}

check_md5() {
    echo "* Checking md5sum"
    md5="$(curl --silent -L $download_url.md5)"
    case "SYSTYPE" in 
        Linux)
        if [ "$(md5sum opensca-cli.tar.gz | awk '{print $1}')" != "$md5" ]; then
            printf "  md5sum check failed, please try again.\n"
            rm opensca-cli.tar.gz
            exit 1
        fi
        ;;
        Darwin)
        if [ "$(md5 opensca-cli.tar.gz | awk '{print $4}')" != "$md5" ]; then
            printf "  md5sum check failed, please try again.\n"
            rm opensca-cli.tar.gz
            exit 1
        fi
        ;;
    esac
}

install() {
    printf "* Installing OpenSCA-cli\n"
    mkdir -p $HOME/.config/opensca-cli
    tar -xzf opensca-cli.tar.gz -C $HOME/.config/opensca-cli
    if [ $UPDATE -eq 0 ]; then
        current_shell=$(echo $SHELL | awk -F '/' '{print $NF}')
        printf "  Adding OpenSCA-cli to PATH: "
        case "$current_shell" in
            "bash")
                printf "'export PATH=$HOME/.config/opensca-cli:\$PATH >> ~/.bashrc'\n"
                echo "export PATH=$HOME/.config/opensca-cli:\$PATH" >> ~/.bashrc
                ;;
            "zsh")
                printf "'export PATH=$HOME/.config/opensca-cli:\$PATH >> ~/.zshrc'\n"
                echo "export PATH=$HOME/.config/opensca-cli:\$PATH" >> ~/.zshrc
                ;;
            *)
                printf "  Unsupported shell: %s, please add $HOME/.config/opensca-cli to your PATH manually.\n" "$current_shell"
                ;;
        esac
        export PATH=$HOME/.config/opensca-cli:$PATH
    fi
    rm opensca-cli.tar.gz
    printf "* Successfully installed OpenSCA-cli to $HOME/.config/opensca-cli. You can start using it by running 'opensca-cli' in your terminal. Enjoy!\n"
}

main() {
    get_system_info

    case "$git" in 
        "gitee")
            latest_version=$(curl --silent "https://gitee.com/api/v5/repos/XmirrorSecurity/OpenSCA-cli/releases/latest" | sed -n 's/.*"tag_name":"\([^"]*\)".*/\1/p')
            download_url="https://gitee.com/XmirrorSecurity/OpenSCA-cli/releases/download/$latest_version/opensca-cli-$latest_version-$SYSTYPE-$SYSARCH.tar.gz"
            ;;
        "github")
            latest_version=$(curl --silent "https://api.github.com/repos/XmirrorSecurity/OpenSCA-cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
            download_url="https://github.com/XmirrorSecurity/OpenSCA-cli/releases/download/$latest_version/opensca-cli-$latest_version-$SYSTYPE-$SYSARCH.tar.gz"
            ;;
    esac
    printf "* The latest version of OpenSCA-cli is: %s\n" "$latest_version"
    download
    check_md5
    install
}

parse_args() {
    git="github"
    while [ $# -gt 0 ]; do
        case "${1}" in
        "-h" | "--help")
            usage
            exit 0
            ;;
        "-v" | "--version")
            printf "OpenSCA install script version: %s\n" "$VERSION"
            exit 0
            ;;
        "gitee")
            git="gitee"
            ;;
        "github")
            git="github"
            ;;
        "update")
            UPDATE=1
            ;;
        *)
            printf "Unknown argument: %s\n" "${1}"
            usage
            exit 1
            ;;
        esac
        shift
    done
    
}

usage() {
    printf "Usage: install.sh [options]\n"
    printf "Options:\n"
    printf "  -h, --help        Show this help message and exit\n"
    printf "  -v, --version     Show version info and exit\n"
    printf "  gitee | github    Download from gitee/github, default: github\n"
    printf "  update            Force update OpenSCA-cli(will not update \$PATH)\n"
}

parse_args "$@"
main
