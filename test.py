from bs4 import BeautifulSoup
import requests
import pandas as pd
import sys
from datetime import datetime
import os
import time
from urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

def check_url_sort_html(check_url):
    # 要查询的 URL
    url = "https://www.fortiguard.com/webfilter"

    # 构建 payload 数据，这里使用一个示例字典
    payload = {
        'url': check_url,
        'webfilter_search_form_submit': 'submit',
        'ver': 9,
    }

    # 设置 User-Agent
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36'  # 替换成你自己的 User-Agent 字符串
    }

    # 发送 POST 请求，传递 payload 数据和请求头
    response = requests.post(url, data=payload, headers=headers,timeout=60,verify=False)

    # 检查响应状态码
    if response.status_code == 200:
        # 处理响应数据
        # 请根据实际情况解析响应数据
        # print(response.text)
        # 使用 BeautifulSoup 解析 HTML
        soup = BeautifulSoup(response.text, 'html.parser')

        # 找到所有 H4 标签
        h4_tags = soup.find_all('h4')

        # 打印 H4 标签的文本内容
        for h4_tag in h4_tags:
            if h4_tag.text.strip().startswith("Category"):
                # print(f"1.域名: {check_url}, 分类信息: {h4_tag.text.strip()}")
                return h4_tag.text.strip()
        return "Category: NONE"    
    else:
        print("无法访问网站")
def check_url_sort_respone(check_url):
    # 要查询的 URL
    url = "https://www.fortiguard.com/webfilter"

    # 构建 payload 数据，这里使用一个示例字典
    payload = {
        'url': check_url,
        'webfilter_search_form_submit': 'submit',
        'ver': 9,
    }

    # 设置 User-Agent
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36'  # 替换成你自己的 User-Agent 字符串
    }

    # 发送 POST 请求，传递 payload 数据和请求头
    response = requests.post(url, data=payload, headers=headers,timeout=60,verify=False)

    # 检查响应状态码
    if response.status_code == 200:
        # 处理响应数据
        # 请根据实际情况解析响应数据
        # print(response.text)
        soup = BeautifulSoup(response.text, 'html.parser')
        category = soup.find('h4', class_='info_title')
        # 打印 H4 标签的文本内容
        category_element = soup.find('h4', class_='info_title')
        if category_element is not None:
            category = category_element.text.replace("Category: ", "")
            # print(f"2.域名: {check_url}, 分类信息: {category}")
            return category
        else:
            print(f"{check_url} 未找到分类信息")
        with open("log.txt", 'a', encoding='utf-8') as file2:
            file2.write(f"{check_url}: ====={response.text}====\n")
            file2.close()
        return "Category: NONE"    
    else:
        print(f"{check_url}: 无法访问网站")
        return "Category: NONE"    

def creat_result_file(src_filename,result_filename_csv,result_filename_excel,formatted_time):
    num=0

    with open(result_filename_csv, 'w', encoding='utf-8') as file1:
            file1.write("id,url,class,class_ntos,ntos_small_cn,ntos_small_other,addtime,Flag_Hand,Class2,state,extra_cls_flag,class_ntos_eng,test,result,time"+"\n")
            file1.close()
    # 打开文件并逐行读取域名
    # 你的代码，可能包括发送HTTP请求的部分

    with open(src_filename, 'r',encoding='utf-8') as file:
        total_start=time.time()
        for line in file:
            # 去除每行两边的空白字符
            line = line.strip()
            if line and not line.startswith("id,"):
                num=num + 1
                develop = line.split(',')[-1]
                # 使用逗号分隔每行的内容
                domain = line.split(',')[1]
                start_time = time.time()
                try:
                    # 调用查询函数并打印结果
    
                    category = check_url_sort_html(domain).replace("Category: ", "")
    
                    if category=="NONE":
                        category = check_url_sort_respone(domain).replace("Category: ", "")
                    
                    if develop in category:
                        result="yes"
                    else:
                        result="no" 
                    end_time = time.time()
                    # 计算时间差，并将结果转换为整数
                    elapsed_time_seconds = int(end_time - start_time)
                    if num >500:
                        num=0
                        print("sleep 10seconds")
                        time.sleep(10)
                    with open(result_filename_csv, 'a', encoding='utf-8') as file2:
                        file2.write(f"{line},{category},{result},{elapsed_time_seconds}\n")
                        file2.close()
                except Exception as e:
                    # 处理其他异常
                    total_end = time.time()
                    # 计算时间差，并将结果转换为整数
                    total_seconds = int(total_end - total_start)
                    print(f"程序持续时间：{total_seconds}")
                    total_start=total_end
                    with open(f"{formatted_time}-input.txt", 'a', encoding='utf-8') as file3:
                        file3.write(f"{line}\n")
                        file3.close()
                    print(f"An error occurred while checking {domain}: {e}")
                    print("sleep 60seconds")
                    time.sleep(60)
    
    #data = pd.read_csv(result_filename_csv, encoding='utf-8',error_bad_lines=False)
    data = pd.read_csv(result_filename_csv, encoding='utf-8')
    writer = pd.ExcelWriter(result_filename_excel, engine="xlsxwriter")

    data.to_excel(writer, 'ok', header=True, index=False)

    workbook  = writer.book

    worksheet = writer.sheets['ok']

    # 垂直对齐方式
    # 水平对齐方式
    # 自动换行

    content_format = workbook.add_format({
        'valign': 'vcenter',
        'align': 'center',
        'text_wrap': True
    }) 

    # worksheet.set_column("A:A",50, content_format)
    # worksheet.set_column("B:B",45, content_format)
    # worksheet.set_column("C:C",10, content_format)
    # worksheet.set_column("D:D",5, content_format)
    # worksheet.set_column("E:E",18, content_format)
    # worksheet.set_column("F:F",75, content_format)

    # 设置所有行高
    # worksheet.set_default_row(82)

    writer.save()
    writer.close()


codepath = os.path.dirname(os.path.abspath(__file__))
now = datetime.now()
formatted_time = now.strftime("%Y%m%d%H%M")
src_filename = "input.csv"
src_filename_path =os.path.join(codepath, "result",src_filename)
result_filename_csv = os.path.join(codepath, "result",f"{formatted_time}.csv")   
result_filename_excel= os.path.join(codepath,"result", f"{formatted_time}.xlsx")

creat_result_file(src_filename_path,result_filename_csv,result_filename_excel,formatted_time)
# check_url_sort_respone("0-limit.com")
# check_url_sort_html("0-limit.com")


