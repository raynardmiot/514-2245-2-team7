import './upload.css';
import './loader.css';

function Loading(props) {

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

            // if data not empty
            //  clearInterval(myInterval);

          })      
          .catch((reason) => {
            console.log("retrieveImage", reason);
          })

          
    }
    
    var myInterval = setInterval(poll, 5000);
    

    return (
        <div className="info">
            <div className="loader"></div>
            <br />
            <p>Processing your photo...</p>
        </div>
        
    )
}

export default Loading;