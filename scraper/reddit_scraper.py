import os, utils


def main():
    subreddit_name = input("Enter the subreddit name: ").replace("r/", "")    
    url = f"https://www.reddit.com/svc/shreddit/community-more-posts/top/?t=ALL&name={subreddit_name}"

    try:
        qty = int(input("Number of pictures to scrape: "))
    except:
        raise RuntimeError("NOOOOOOOOO you're supposed to put a number oouuughhhgh 😭😭😭😭")


    links = utils.get_img_links_from_url(url, qty)
    count = 1

    os.makedirs(subreddit_name, exist_ok=True)

    for link in links:
        utils.download_image(link, f"{subreddit_name}/{count}.jpg")
        print(f"Downloading images: {count}/{qty}", end="\r")
        count += 1

    print(f"\nDone ({qty} images downloaded to directory '{subreddit_name}')")

# the python thing
if __name__ == "__main__":
    main()