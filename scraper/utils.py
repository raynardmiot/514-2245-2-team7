import requests, time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options

HTTP_OK = 200

def get_img_links_from_url(url: str, qty: int) -> set[str]:
    links = set()
    
    options = Options()
    options.add_argument("--headless")

    driver = webdriver.Firefox(options=options)
    driver.get(url)

    # Scroll to bottom of page to load more images until we have enough
    while len(links) < qty:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        imgs = driver.find_elements(By.XPATH, "//img[contains(@src, 'https://preview.redd.it')]")

        # Exclude string "avatar" to exclude pfps and ".png" because ads are PNGs (unlike posts which are JPEGs) and we don't want ads
        links = links.union(set([img.get_attribute("src") for img in imgs if "avatar" not in img.get_attribute("src") and ".png" not in img.get_attribute("src")]))
        print(f"Getting image URLs: {len(links)}/{qty}", end="\r")

    print(f"Getting image URLs: {qty}/{qty}")

    # Trim excess results
    while len(links) > qty:
        links.pop()

    driver.quit()
    return links

def download_image(url: str, filepath: str):
    response = requests.get(url)

    if response.status_code != HTTP_OK:
        return
    
    with open(filepath, "wb") as file:
        file.write(response.content)