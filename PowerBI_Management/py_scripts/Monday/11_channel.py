# -*- coding: utf-8 -*-
"""
Created on Tue Jun  8 14:54:16 2021

@author: HLai
"""

channel = "https://analog.crm.dynamics.com/main.aspx?appid=4283a7fa-79a8-e811-a843-000d3a37c848&etn=opportunity&pagetype=entitylist&viewType=4230&viewid=%7BBA5AEB29-45C3-EB11-BACC-002248048654%7D"
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait;
from selenium.webdriver.common.action_chains import ActionChains;
import time;
import datetime;
import os;

Current_Date = datetime.datetime.today().strftime ('%Y-%m-%d');
folder = r'C:\Users\hlai\OneDrive - Analog Devices, Inc\Documents\Pipeline_PowerBI\Archive'
date_folder = folder + '\\'+Current_Date+'\\channel';
if not os.path.exists(date_folder):
    os.makedirs(date_folder)

options = webdriver.ChromeOptions()
prefs = {"download.default_directory" : date_folder}
options.add_experimental_option("prefs",prefs)
options.add_argument("--start-maximized")
driver = webdriver.Chrome(ChromeDriverManager().install(), chrome_options=options)
#open browswer
action = ActionChains(driver);
driver.get(channel);

wait = WebDriverWait(driver, 20)
time.sleep(1)

wait.until(lambda x:x.find_element_by_id('i0116')).send_keys("Hilary.Lai@analog.com")
time.sleep(2)
wait.until(lambda x:x.find_element_by_id('idSIButton9')).click()
time.sleep(2)
wait.until(lambda x:x.find_element_by_id('passwordInput')).send_keys("Eabono1215!")
time.sleep(2)
wait.until(lambda x:x.find_element_by_id('submitButton')).click()
time.sleep(2)
wait.until(lambda x:x.find_element_by_id('idSIButton9')).click()

time.sleep(20)
hamb = wait.until(lambda x:x.find_element_by_id('OverflowButton_button0_opportunity$button'))
hamb.click()
time.sleep(2)
export = wait.until(lambda x:x.find_element_by_xpath('//span[text()="Export to Excel"]'))
export.click()

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
        read_file.to_csv(r'C:\Users\hlai\Analog Devices, Inc\APR-Data-Team - Power BI Development\Project\pipeline\channel.csv', index = None, header=True)
        driver.close()