import * as React from "react"
import { Link } from "gatsby"
//import { useState, useEffect} from 'react'

import Layout from "../components/layout"
import {Seo} from "../components/seo"

const Start = () => (
  <Layout>
    <div className="container text-center my-5">
      <h1> Start</h1>
      <p> To start the process and save energy, upload the image of your floorplan here.</p>
      
      <input className="form-control" type ="file" id="image-input" accept="image/jpeg, image/png, image/jpg"/>
      <div className="row">
        <Link to="/verification/" className="btn btn-primary my-2">Recognize my rooms</Link>
        <Link to="/" className="btn btn-secondary my-2">Home</Link>
      </div>
    </div>
  </Layout>
)

// function UploadImages(){
//   const [images, setImages] = useState([]);
//   const [imageURLs, setImageURLs] = useState([]);

//   useEffect(() => {
//     const newImageUrls = [];
//     images.forEach(image => newImageUrls.push(URL.createObjectURL(image)));
//     setImageURLs(newImageUrls);
//   }, [images]);

//   function onImageChange(e) {
//     setImages([...e.target.files])
//   }

//   return(
//     <>
//       <input type ="file" onChange={onImageChange} className="form-control" id="image-input" multiple accept="image/jpeg, image/png, image/jpg"/>
//       {imageURLs.map(imageSrc => <img src = {imageSrc} /> )}
//     </>
//   )
// }

// //https://www.pluralsight.com/guides/how-to-use-a-simple-form-submit-with-files-in-react
// const FileUploader = ({onFileSelect}) => {
//   const fileInput = useRef(null)

//   const handleFileInput = (e) => {
//       // handle validations
//       onFileSelect(e.target.files[0])
//   }

//   return (
//       <div className="file-uploader">
//           <input type="file" onChange={handleFileInput}/>
//           <button onClick={e => fileInput.current && fileInput.current.click()} className="btn btn-primary"/>
//       </div>
//   )
// }

// const App = () => {
//   const [name, setName] = useState("");
//   const [selectedFile, setSelectedFile] = useState(null);

//   const submitForm = () => {

//     const formData = new FormData();
//     formData.append("name", name);
//     formData.append("file", selectedFile);
  
//     axios
//       .post(UPLOAD_URL, formData)
//       .then((res) => {
//         alert("File Upload success");
//       })
//       .catch((err) => alert("File Upload Error"));
//   };

//   return(
//     <div className="App">
//     <form>
//       <input
//         type="text"
//         value={name}
//         onChange={(e) => setName(e.target.value)}
//       />
//       <input
//         type="file"
//         value={selectedFile}
//         onChange={(e) => setSelectedFile(e.target.files[0])}
//       />
//       <FileUploader
//         onFileSelectSuccess={(file) => setSelectedFile(file)}
//         onFileSelectError={({ error }) => alert(error)}
//       />
//     </form>
//     </div>
//   )
// }

export default Start

export const Head = () => (
    <Seo title="Start" />
)
 