{ pkgs, ... }:
# TODO: Move this to my nixos config instead lol.
pkgs.writeShellApplication {
  name = "wake-home";

  # Dependencies required by the script
  runtimeInputs = with pkgs; [
    iputils # for ping
    networkmanager # for nmcli
    openssh # for ssh to Mikrotik
    gnugrep # for grep
    coreutils # for sleep, cut, echo
    wakeonlan # if you want the 'wol' command to work locally
  ];

  text = ''
    # --- CONFIG ---
    VPN_NAME="wg0"                  # Name of your VPN in NetworkManager
    TARGET_MAC="60:45:CB:71:43:33"  # Home PC MAC address
    TARGET_IP="192.168.70.3"        # Home PC IP

    MIKROTIK_IP="10.200.200.2"

    IS_TAILSCALE=0
    VPN_COMMAND="ssh mikrotik '/tool wol interface=BR-OUT mac=$TARGET_MAC'"

    # --- FUNCTIONS ---

    is_awake() {
        # Usage: is_awake <IP> [retries] [interval]
        local ip="$1"
        local retries="''${2:-1}"
        local interval="''${3:-2}"
        for ((i=1; i<=retries; i++)); do
            if ping -c 1 -W 2 "$ip" &> /dev/null; then
                return 0  # device is awake
            fi
            sleep "$interval"
        done
        return 1  # device did not respond
    }

    get_ssid() {
        nmcli -t -f NAME,DEVICE c show --active | grep wlp1s0 | cut -d: -f1
    }

    check_vpn() {
        ip link show "$VPN_NAME" &>/dev/null
        #nmcli con show --active | grep -q "^$VPN_NAME"
    }

    connect_vpn() {
        nmcli con up id "$VPN_NAME" &>/dev/null
    }

    disconnect_vpn() {
        nmcli con down id "$VPN_NAME" &>/dev/null
    }

    # --- MAIN ---

    print_info() {
        echo "TARGET: $TARGET_IP ($TARGET_MAC)"
        echo "Current SSID: $(get_ssid)"
    }

    check_internet() {
        echo "Checking for internet connectivity:"
        if ! is_awake 8.8.8.8; then
            echo "  Must have internet connection. Exiting."
            exit 1
        fi
        echo "  Internet connected!"
    }

    start_vpn() {
        read -r -p "Send WOL directly? (y/n): " answer
        case "$answer" in
            y|Y|yes|YES)
                echo "Sending WOL."
                wakeonlan $TARGET_MAC
                exit 0
                ;;
            *)
        esac
        if ! check_vpn; then
            echo "VPN '$VPN_NAME' is not connected."
            read -r -p "Do you want to connect to the VPN? (y/n): " answer
            case "$answer" in
                y|Y|yes|YES)
                    echo "Connecting to VPN '$VPN_NAME'..."
                    if connect_vpn; then
                        echo "VPN connected!"
                    else
                        echo "Failed to connect to VPN. Exiting."
                        exit 1
                    fi
                    ;;
                *)
                    echo "VPN not connected."
                    read -r -p "Do you want to continue (use tailscale)? (y/n): " answer
                    case "$answer" in
                        y|Y|yes|YES)
                            echo "Continuing without VPN"
                            TARGET_IP="acrylic"
                            IS_TAILSCALE=1
                            ;;
                        *)
                            echo "Exiting."
                            exit 0
                            ;;
                    esac
                    ;;
            esac
        fi
        echo
    }

    check_home_conn() {
        echo "Checking if HOME PC is awake:"
        if is_awake $TARGET_IP; then
            echo "  Device $TARGET_IP is already awake. Exiting."
            exit 0
        fi
        echo "  Device $TARGET_IP is asleep."

        echo "Checking if Mikrotik Router is awake:"
        if ! check_vpn ; then
            if ! connect_vpn ; then
                echo "Failed to connect to vpn to check if mikrotik is awake"
                exit 1
            fi
        fi
        if ! is_awake $MIKROTIK_IP ; then
            echo "  Mikrotik ($MIKROTIK_IP) is not awake/can't ping. Exiting."
            exit 0
        fi
        echo "  Mikrotik ($MIKROTIK_IP) is awake."
    }

    wake_and_wait() {
        echo "Sending WoL to Home PC..."
        eval "$VPN_COMMAND"
        if [[ "$IS_TAILSCALE" -eq 1 ]] ; then
            disconnect_vpn
        fi
        echo "WoL packet sent. Waiting for Home PC to respond to ping..."

        if is_awake $TARGET_IP 20; then
            echo "Device $TARGET_IP is now awake!"
        else
            echo "Device $TARGET_IP did not respond after WOL."
        fi
    }

    # --- MAINMAINFRFR ---

    print_info
    check_internet
    start_vpn
    check_home_conn
    wake_and_wait

  '';
}
