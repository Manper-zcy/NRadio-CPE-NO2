import socket
import sys

# Unix Domain Socket 文件路径
SOCKET_FILE = "/tmp/at_socket.sock"
CONFIG_FILE = "/tmp/modconf-AK68.conf"
TIMEOUT_SECONDS = 3  # 超时时间为3秒

def check_config_file():
    """
    检查配置文件是否包含指定文本
    """
    try:
        with open(CONFIG_FILE, 'r') as file:
            contents = file.read()
            if "RM520N" in contents:
                return True
            else:
                print(f"Error: '{CONFIG_FILE}' does not contain 'RM520N'. Exiting.")
                return False
    except FileNotFoundError:
        print(f"Error: Configuration file '{CONFIG_FILE}' not found.")
        return False

def send_command_to_client(command):
    """
    将命令发送给后台程序，并接收响应
    """
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client_socket:
            client_socket.settimeout(TIMEOUT_SECONDS)  # 设置接收超时时间
            client_socket.connect(SOCKET_FILE)

            # 发送命令
            client_socket.sendall(command.encode())

            try:
                # 接收响应，设置接收超时时间
                response = client_socket.recv(4096).decode()
                if response:
                    print(response)
            except socket.timeout:
                print(f"Error: No response received within {TIMEOUT_SECONDS} seconds.")
    except Exception as e:
        print(f"Error: {e}")

def main(argv):
    if len(argv) < 2:
        print("Usage: python3 at_terminal.py <command>")
        return 1

    # 检查配置文件
    if not check_config_file():
        return 1

    command = argv[1]
    send_command_to_client(command)
    return 0

if __name__ == "__main__":
    main(sys.argv)

