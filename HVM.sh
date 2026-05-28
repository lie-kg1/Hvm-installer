#!/bin/bash

# ==========================================
# COLOR DEFINITIONS (ANSI Escape Codes)
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (Reset)

# ==========================================
# ENVIRONMENT PREPARATION FUNCTION
# ==========================================
vps_prepare_env() {
    echo -e "${YELLOW}Checking and installing required system dependencies...${NC}"
    local tools=(git unzip python3 curl)
    local to_install=()

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            to_install+=("$tool")
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo -e "${BLUE}Installing missing tools: ${to_install[*]}${NC}"
        sudo apt-get update -y && sudo apt-get install -y "${to_install[@]}" || \
        sudo yum install -y "${to_install[@]}"
    fi
}

# ==========================================
# MAIN MENU FUNCTION
# ==========================================
vps_panels_menu() {
    # Store the original starting directory safely
    local MAIN_DIR=$(pwd)

    while true; do
        clear
        # Colorful Box-Drawn Interface
        echo -e "${CYAN}╔═════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}             ${YELLOW}VPS PANELS${NC}              ${CYAN}║${NC}"
        echo -e "${CYAN}╠═════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC}      ${YELLOW}Server VPS Panel Manager${NC}       ${CYAN}║${NC}"
        echo -e "${CYAN}╠═════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC}                                     ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${GREEN}1.${NC} HVM & VPS Bot                   ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${GREEN}2.${NC} SVM Panel                       ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}                                     ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${RED}0.${NC} Back / Exit                     ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}                                     ${CYAN}║${NC}"
        echo -e "${CYAN}╚═════════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option: " vps_choice

        case $vps_choice in
            1)
                echo -e "\n${GREEN}Launching HVM Installer...${NC}"
                bash <(curl -fsSL https://raw.githubusercontent.com/lie-kg1/HVM5.1/main/LP-Hvm-Installer.sh)
                
                echo -e "\n${YELLOW}Press Enter to return to menu...${NC}"
                read -r
                ;;

            2)
                # Run dependency check
                vps_prepare_env

                echo -e "\n${GREEN}Cloning SVM repository...${NC}"
                # Wipe any broken/previous clones to avoid directory errors
                rm -rf HVMvotex 
                
                if git clone https://github.com/gangfreefireboy-svg/HVMvotex; then
                    cd HVMvotex || exit
                    
                    echo -e "\n${GREEN}Running installer script...${NC}"
                    if bash install.sh; then
                        echo -e "\n${GREEN}Extracting SVM files...${NC}"
                        if unzip -q Svm-v5.zip; then
                            echo -e "\n${GREEN}Starting SVM Application...${NC}"
                            python3 svm.py
                        else
                            echo -e "\n${RED}❌ Error: Failed to extract Svm-v5.zip${NC}"
                        fi
                    else
                        echo -e "\n${RED}❌ Error: install.sh execution failed.${NC}"
                    fi
                else
                    echo -e "\n${RED}❌ Error: Failed to clone repository.${NC}"
                fi
                
                # Crucial: Always return back to the main directory before looping
                cd "$MAIN_DIR" || exit
                echo -e "\n${YELLOW}Press Enter to return to menu...${NC}"
                read -r
                ;;

            0)
                echo -e "\n${BLUE}Exiting Manager...${NC}"
                break
                ;;

            *)
                echo -e "\n${RED}Invalid option! Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# ============ EXECUTION ============
vps_panels_menu
