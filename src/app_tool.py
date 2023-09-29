import json
import os
import re
import requests
import sys
import demo
import difflib
from bs4 import BeautifulSoup

def getappdate1(date,username,passworde):
    ntos_page = date
    login_api = f"{ntos_page}/api/v1/login/"
    res=demo.login_web(login_api,ntos_page,username,passworde)
    sessionid=res["session_id"]
    csrftoken=res["csrftoken"]
    cookie = f"LOCAL_LANG_i18n=en;csrftoken={csrftoken};sessionid={sessionid}"
    url = f"{ntos_page}/api/v1/application/"
    headers = {
    "cookie": cookie,
}
    response =  requests.get(url,headers=headers,verify=False)

    # print(response.text)
    str1=json.loads(response.text)
    # print(type(str1))
    list1=str1["data"]["list"]
    return list1



def check_app_name_online(app_name):
    url = f'https://www.baidu.com/s?wd={app_name}'
    response = requests.get(url, verify=False)
    soup = BeautifulSoup(response.content, 'html.parser')
    h3_list = soup.find_all('h3')
    for h3 in h3_list:
        print(h3.text)  # 输出H3标签的文本内容

# check_app_name_online("QQ空间")

def check_app_name(date="https://10.51.212.211",username="admin",passworde="Ruijie@123"):
    codepath = os.path.dirname(os.path.abspath(__file__))
    path=os.path.join(codepath, "file/")
    fielname=path+"10.51.212.212-en"
    print("检测应用名规范性")
    list1=getappdate1(date,username,passworde)
    for first_list in list1:
        for sec_list in first_list["sub_class_list"]:
            if not sec_list["app_list"]:
                print(f"{sec_list['desc_name']}不存在3级菜单")
                print(f"检测{sec_list['desc_name']}规范性")
            else:
                for third_list in sec_list["app_list"]:
                    # print("1级："+first_list["desc_name"]+"==2级： "+sec_list["desc_name"]+"==3级： "+third_list["desc_name"])
                    print(f"检测{third_list['desc_name']}规范性")







def has_chinese(string):
    pattern = re.compile(r'[\u4e00-\u9fa5]')
    match = pattern.search(string)
    return match is not None



def compare_file(filename,language,level):
    # print("开始对比")
    codepath = os.path.dirname(os.path.abspath(__file__))
    path=os.path.join(codepath, "file/")
    with open(f'{path}standard-{language}-{level}级.txt', 'r',encoding='utf-8') as file1:
        file1_lines = file1.readlines()
    # 读取第二个文件
    with open(f'{filename}-{level}级.txt', 'r',encoding='utf-8') as file2:
        file2_lines = file2.readlines()
    differ = difflib.Differ()
    diff = list(differ.compare(file1_lines, file2_lines))
    # print(diff)

    flag=True
    app=""
    version="version: "
    for line in diff:
        if "app_version" in line:
            version=version+f'{line[14:].strip()}"==>"'
        elif line.startswith('+') and line.replace('+','-') not in diff:
            # print(f'{language}：【ADD】{line[1:].strip()}\r\n')
            app=app+f'\t{language}：【ADD】{line[1:].strip()}'+"\n"
            flag=False
        elif line.startswith('-') and line.replace('-','+') not in diff:
            flag=False
            app=app+f'\t{language}：【DEL】{line[1:].strip()}'+"\n"
            # print(f'{language}：【DEL】{line[1:].strip()}\r\n')
        elif line.startswith('?'):
            pass   # 忽略差异行中的无关符号
        else:
            pass   # 两文件相同行，不进行处理
    version=version[:-4]
    if flag:
        return f"\tapplication name not change"+"\n",version
    else:
        return  app,version


def getappdate(date,language,username,password,filepath="result.txt"):
    app1_1=""
    app2_1=""
    app3_1=""
    ntos_page = date
    login_api = f"{ntos_page}/api/v1/login/"
    # res=demo.login_web(login_api,ntos_page,username,password)
    if language == "en":
        web_language = "en"
    else:
        web_language = "ch"

    res=demo.login_web(login_api,ntos_page,username,password)
    sessionid=res["session_id"]
    csrftoken=res["csrftoken"]
    cookie = f"LOCAL_LANG_i18n={web_language};csrftoken={csrftoken};sessionid={sessionid}"
    url_app = f"{ntos_page}/api/v1/application/"
    url_version = f"{ntos_page}/api/v1/feature_library/getData/"
    headers = {
    "cookie": cookie,
}
    version =  requests.get(url_version,headers=headers,verify=False)
    str2=json.loads(version.text)
    version=str2["data"]["list"][0]["current-version"]
    # print(version)

    response =  requests.get(url_app,headers=headers,verify=False)

    # print(response.text)
    str1=json.loads(response.text)
    list1=str1["data"]["list"]
    codepath = os.path.dirname(os.path.abspath(__file__))
    path=os.path.join(codepath, "file/")
    fielname=path+ntos_page.split("//")[1]+"-"+language
    # fielname=path+"standard"+"-"+language
    with open(f'{fielname}-1级.txt', 'w', encoding='utf-8') as file1:
        file1.write(f"app_version: {version}"+"\n")
        file1.write("Level_1"+"\n")
        file1.close()
    with open(f'{fielname}-2级.txt', 'w', encoding='utf-8') as file2:
        file2.write(f"app_version: {version}"+"\n")
        file2.write("Level_2"+"\n")
        file2.close()
    with open(f'{fielname}-3级.txt', 'w', encoding='utf-8') as file3:
        file3.write(f"app_version: {version}"+"\n")
        file3.write("Level_3"+"\n")
        file3.close()
    # my_list = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    if language=="en":
        for first_list in list1:
            # print(first_list["desc_name"])
            # print("1级："+first_list["desc_name"])
            if(has_chinese(first_list["desc_name"])):
                app1_1=app1_1+"\tExist Chinese: "+first_list["desc_name"]+"\r\n"
            with open(f'{fielname}-1级.txt', 'a', encoding='utf-8') as file1:
                file1.write("Level_1："+first_list["desc_name"]+"\n")
                file1.close()
            for sec_list in first_list["sub_class_list"]:
                if(has_chinese(sec_list["desc_name"])):
                    app2_1=app2_1+"\tExist Chinese: "+sec_list["desc_name"]+"\r\n"
                with open(f'{fielname}-2级.txt', 'a', encoding='utf-8') as file2:
                    file2.write("Level_2： "+sec_list["desc_name"]+"\n")
                    file2.close()
                for third_list in sec_list["app_list"]:
                    if(has_chinese(third_list["desc_name"])):
                        app3_1=app3_1+"\tExist Chinese: "+third_list["desc_name"]+"\r\n"
                    with open(f'{fielname}-3级.txt', 'a', encoding='utf-8') as file3:
                        file3.write("Level_3： "+third_list["desc_name"]+"\n")
                        file3.close()
        if app1_1 == "":
            app1_1="\tChinese does not exist\n\n"
        else:
            app1_1=app1_1+"\n\n"
        if app2_1 == "":
            app2_1="\tChinese does not exist\n\n"
        else:
            app2_1=app2_1+"\n\n"
        if app3_1 == "":
            app3_1="\tChinese does not exist\n\n"
        else:
            app3_1=app3_1+"\n\n"
    else:
        for first_list in list1:
            with open(f'{fielname}-1级.txt', 'a', encoding='utf-8') as file1:
                file1.write("Level_1："+first_list["desc_name"]+"\n")
                file1.close()
            for sec_list in first_list["sub_class_list"]:
                with open(f'{fielname}-2级.txt', 'a', encoding='utf-8') as file2:
                    file2.write("Level_2： "+sec_list["desc_name"]+"\n")
                    file2.close()
                for third_list in sec_list["app_list"]:
                    with open(f'{fielname}-3级.txt', 'a', encoding='utf-8') as file3:
                        file3.write("Level_3： "+third_list["desc_name"]+"\n")
                        file3.close()

    app1,version1=compare_file(fielname,language,1)
    app2,version2=compare_file(fielname,language,2)
    app3,version3=compare_file(fielname,language,3)
    with open(filepath, 'a', encoding='utf-8') as file1:
        file1.write(f"{version1}\n")
        file1.write("First level menu：\n")
        file1.write(f"{app1}\n{app1_1}")
        file1.write("Second level menu：\n")
        file1.write(f"{app2}\n{app2_1}")
        file1.write("Third level menu：\n")
        file1.write(f"{app3}\n{app3_1}")
        file1.close()



# if __name__ == "__main__":
#     # codepath = os.path.dirname(os.path.abspath(__file__))
#     # path=os.path.join(codepath, "file/")
#     # fielname=path+"10.51.212.212-en"

# /usr/bin/python /home/release/src/app_tool.py
#海外
# getappdate("https://10.51.212.212","en","admin","Ruijie@123","test.txt")

#国内
# getappdate("https://10.51.212.211","ch","admin","Ruijie@123","test.txt")
#小库
# getappdate("https://10.51.212.32","small","admin","ruijie@123","test.txt")

# codepath = os.path.dirname(os.path.abspath(__file__))
# path=os.path.join(codepath, "file/")
# fielname=path+"10.51.212.211-ch"
# app1,version1=compare_file(fielname,"ch",1)
# print(type(app1))
# print(app1)
# print(version1)

