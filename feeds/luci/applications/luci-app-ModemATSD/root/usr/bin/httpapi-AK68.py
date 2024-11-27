import asyncio
import websockets
import subprocess
import sys

WS_PORT = 5001

# 异步处理外部命令并通过 WebSocket 发送结果
async def execute_command_and_send(command, websocket):
    commands = f"atsd_tools_cli -i cpe -c '{command}'"
    process = subprocess.Popen(commands, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = process.communicate()
    
    decoded_string = stderr if stderr else stdout
    await websocket.send(decoded_string)

# WebSocket 处理函数
async def handle_websocket(websocket, path):
    async for message in websocket:
        print(f"Received command from frontend: {message}")
        await execute_command_and_send(message, websocket)

# 检查是否有 'httpapi.py' 进程正在运行
#def check_if_httpapi_running():
    #try:
        # 在 Windows 上使用 tasklist，在 Linux 上使用 ps -ef
        #process = subprocess.Popen(['ps', '-ef'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        #stdout, _ = process.communicate()
        # 检查 'httpapi.py' 是否在进程列表中
        #return 'httpapi.py' in stdout
    #except Exception as e:
        #print(f"Error checking processes: {e}")
        #return False

# 启动 WebSocket 服务器
async def start_websocket_server():
    #if check_if_httpapi_running():
        #print("httpapi.py is already running. Exiting.")
        #sys.exit(0)
    
    async with websockets.serve(handle_websocket, "0.0.0.0", WS_PORT):
        print(f"WebSocket server running on port {WS_PORT}...")
        await asyncio.Future()  # 保持服务器运行

if __name__ == "__main__":
    asyncio.run(start_websocket_server())


