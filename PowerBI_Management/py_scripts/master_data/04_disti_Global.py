# -*- coding: utf-8 -*-
"""
Created on Tue Jul 13 16:36:17 2021

@author: HLai
"""

disti_global = "https://qv.web.analog.com/QvAJAXZfc/opendoc.htm?document=sales%5Cckm%5Fdashboard%5Fpos.qvw&bookmark=Server\BM2302-28&host=QVS@QVCluster"
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
date_folder = folder + '\\'+Current_Date+'\\distiGlobal';
if not os.path.exists(date_folder):
    os.makedirs(date_folder)

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : date_folder}
options.add_experimental_option("prefs",prefs)
driver = webdriver.Chrome(ChromeDriverManager().install(), chrome_options=options)
#open browswer
action = ActionChains(driver);
driver.get(disti_global);
driver.refresh();

time.sleep(2)
wait = WebDriverWait(driver, 20)
report = wait.until(lambda x:x.find_element_by_xpath(('//div[text() = "Purchasing View Extract"]')))
time.sleep(1)
action.move_to_element(report).context_click(report).perform()
export = wait.until(lambda x:x.find_element_by_xpath(('//li[contains(@class,"ctx-menu-action-EC")]')))
time.sleep(1)
export.click()

import glob

timeout = time.time() + 60*15
while len(glob.glob(date_folder+"\\*.csv"))==0:
    time.sleep(1)
    if time.time() > timeout:
        break

if len(glob.glob(date_folder+"\\*.csv"))==1:
    for file in glob.glob(date_folder+"\\*.csv"):
        shutil.copy(file, r'C:\Users\hlai\Analog Devices, Inc\APR-Data-Team - Power BI Development\Project\revenue\DIM_Disti_Global.csv')
        driver.close()