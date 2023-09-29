import subprocess

# 定义Git命令
git_command = "git log --name-status -- '*.py' '*.sh'"

# 执行Git命令并捕获输出
try:
    result = subprocess.check_output(git_command, shell=True, text=True)
    print(result)
except subprocess.CalledProcessError as e:
    print(f"Git command failed with error: {e}")
