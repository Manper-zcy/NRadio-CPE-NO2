import socket
import time
import os

SERVER_IP = "192.168.225.1"
SERVER_PORT = 1555
BUFFER_SIZE = 2048 * 4
RETRY_DELAY = 2  # 每次重试等待时间（秒）

# Unix Domain Socket 文件路径
SOCKET_FILE = "/tmp/at_socket.sock"

def send_command(client_socket, command):
    """
    发送AT指令并等待响应
    """
    buffer_send = bytearray(BUFFER_SIZE)
    # 构建指令
    data_length = len(command) + 1
    buffer_send[3:3+len(command)] = command.encode()
    buffer_send[3+len(command)] = ord('\r')
    # 设置协议头
    buffer_send[0] = 0xa4
    buffer_send[1] = (data_length >> 8) & 0xFF
    buffer_send[2] = data_length & 0xFF
    # 发送数据
    client_socket.send(buffer_send[:3 + data_length])

def receive_response(client_socket):
    """
    接收服务器响应，并检测是否为指令处理结束标志（OK或ERROR）
    """
    try:
        response = ""
        while True:
            rv = client_socket.recv(BUFFER_SIZE)
            if not rv:
                break  # 服务器关闭连接
            offset = 0
            while len(rv) - offset >= 3:
                length = (rv[offset + 1] << 8) | (rv[offset + 2] & 0xFF)
                if len(rv) - offset < 3 + length:
                    break  # 数据包不完整，等待更多数据
                data_payload = rv[offset + 3 : offset + 3 + length]
                
                # 修复：保持换行符并清除不需要的字符串
                decoded_string = data_payload.decode(errors='ignore').replace("RGMII_ATC_READY", "").strip("\x00")
                
                if decoded_string:
                    # 保留换行符，避免它们被替换或丢失
                    #response += decoded_string + "\n"
                    response += decoded_string

                # 跳过当前包
                offset += 3 + length
            
            # 检查是否收到完整的响应（包含OK或ERROR）
            if "OK" in response or "ERROR" in response:
                break  # 收到OK或ERROR，认为指令处理完成

    except socket.timeout:
        pass

    return response


def handle_commands(client_socket):
    """
    用于处理从终端接收到的命令并与服务器通信
    """
    # 如果本地Unix Socket文件存在，先删除它
    if os.path.exists(SOCKET_FILE):
        os.remove(SOCKET_FILE)

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as unix_socket:
        unix_socket.bind(SOCKET_FILE)
        unix_socket.listen(1)
        print(f"Listening for commands on {SOCKET_FILE}")

        while True:
            conn, _ = unix_socket.accept()
            with conn:
                command = conn.recv(1024).decode().strip()
                if command:
                    print(f"Received command: {command}")
                    send_command(client_socket, command)
                    response = receive_response(client_socket)
                    # 将响应发送回终端
                    conn.sendall(response.encode())

def main():
    while True:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
                client_socket.settimeout(10)  # 设置超时时间
                client_socket.connect((SERVER_IP, SERVER_PORT))
                print("Connected to server.")
                handle_commands(client_socket)
        except socket.timeout:
            print("Connection timeout, retrying...")
        except Exception as e:
            print(f"Error: {e}")
        time.sleep(RETRY_DELAY)

if __name__ == "__main__":
    main()
