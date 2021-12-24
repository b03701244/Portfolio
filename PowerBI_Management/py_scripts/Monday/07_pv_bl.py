# -*- coding: utf-8 -*-
"""
Created on Tue Apr  6 15:04:38 2021

@author: HLai
"""

pvbl = "https://qv.web.analog.com/QvAJAXZfc/opendoc.htm?document=key%5Faccounts%5Cbacklog%5Fapp.qvw&bookmark=Server\BM3308-28&host=QVS@QVCluster"
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
date_folder = folder + '\\'+Current_Date+'\\pv_backlog';
if not os.path.exists(date_folder):
    os.makedirs(date_folder)

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : date_folder}
options.add_experimental_option("prefs",prefs)
options.add_argument("--start-maximized")
driver = webdriver.Chrome(ChromeDriverManager().install(), chrome_options=options)
#open browswer
action = ActionChains(driver);
driver.get(pvbl);
driver.refresh();

wait = WebDriverWait(driver, 20)
time.sleep(2)
report = wait.until(lambda x:x.find_element_by_xpath(('//div[@title="Send to Excel"]')))
time.sleep(2)
action.move_to_element(report).context_click(report).perform()
time.sleep(1)
export = wait.until(lambda x:x.find_element_by_xpath(('//li[contains(@class,"ctx-menu-action-EC")]')))
time.sleep(1)
export.click()

import glob

timeout = time.time() + 60*10
while len(glob.glob(date_folder+"\\*.csv"))==0:
    time.sleep(1)
    if time.time() > timeout:
        break

if len(glob.glob(date_folder+"\\*.csv"))==1:
    for file in glob.glob(date_folder+"\\*.csv"):
        shutil.copy(file, r'C:\Users\hlai\Analog Devices, Inc\APR-Data-Team - Power BI Development\Project\revenue\pv_backlog.csv')
        driver.close()