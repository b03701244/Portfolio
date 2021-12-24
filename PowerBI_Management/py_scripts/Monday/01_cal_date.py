# -*- coding: utf-8 -*-
"""
Created on Tue Apr  6 17:24:42 2021

@author: HLai
"""

cal_date = "https://qv.web.analog.com/QvAJAXZfc/opendoc.htm?document=enterprise%5Cmaster%5Fdata%5Fcalendar.qvw&bookmark=Server\BM107-26&host=QVS@QVCluster"
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait;
from selenium.webdriver.common.action_chains import ActionChains;
import time;
import datetime;
import os;
import shutil;

Current_Date = datetime.datetime.today().strftime ('%Y-%m-%d');
folder = r'C:\Users\hlai\OneDrive - Analog Devices, Inc\Documents\Pipeline_PowerBI\Archive'
date_folder = folder + '\\'+Current_Date+'\\Calendar_Date';
if not os.path.exists(date_folder):
    os.makedirs(date_folder)

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : date_folder}
options.add_experimental_option("prefs",prefs)
options.add_argument("--start-maximized")
driver = webdriver.Chrome(ChromeDriverManager().install(), chrome_options=options)
#open browswer
action = ActionChains(driver);
driver.get(cal_date);
driver.refresh();

time.sleep(5)
wait = WebDriverWait(driver, 20)
time.sleep(3)
report = wait.until(lambda x:x.find_element_by_xpath(('//div[@title = "Send to Excel"]')))
time.sleep(2)
report.click()
 
import glob
import pandas as pd

timeout = time.time() + 60*20
while len(glob.glob(date_folder+"\\*.xlsx"))==0:
    time.sleep(1)
    if time.time() > timeout:
        break

if len(glob.glob(date_folder+"\\*.xlsx"))==1:
    for file in glob.glob(date_folder+"\\*.xlsx"):
        read_file = pd.read_excel(file)
        read_file.to_csv(r'C:\Users\hlai\Analog Devices, Inc\APR-Data-Team - Power BI Development\Project\master_data\Calendar_Date.csv', index = None, header=True)
        driver.close()