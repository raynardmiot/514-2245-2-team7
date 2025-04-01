import './upload.css';
import './loader.css';

DB_NAME = 'CatImageLabels'


function Loading(props) {
    imageName = "catImage.jpg";

    const BASE_URL = process.env.REACT_APP_BASE_API_URL;
    url = BASE_URL + "testing/getResults?file_name=" + imageName
    
    function poll() {
        fetch(url, {
            method: 'GET',
            headers: {
              "Access-Control-Allow-Origin": "*",
            },
          }).then(response => response.json())
          .then(data => {
            console.log(data);
            // subreddit;
            // accuracy;
          })
    }

    return (
        <div className="info">
            <div className="loader"></div>
            <br />
            <p>Processing your photo...</p>
            <Button className="button pollButton" onClick={() => poll()}>Poll</Button>
        </div>
        
    )
}

export default Loading;