import './upload.css';
import BASE_CAT_PHOTO from '../cat_photos/whitechat.png';

function UploadSection(props) {
    return (
        <div className="photo">
            <img src={props.photo != undefined ? props.photo : BASE_CAT_PHOTO} alt={props.altText} />
        </div>
    )
}

export default UploadSection;