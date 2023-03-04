import * as React from "react"
import { Link } from "gatsby"
import { useState, useEffect} from 'react'


import Layout from "../components/layout"
import {Seo} from "../components/seo"


//https://stackoverflow.com/questions/38049966/get-image-preview-before-uploading-in-react+
const Start = () => {
  const [selectedFile, setSelectedFile] = useState()
  const [preview, setPreview] = useState()

  // create a preview as a side effect, whenever selected file is changed
  useEffect(() => {
      if (!selectedFile) {
          setPreview(undefined)
          return
      }

      const objectUrl = URL.createObjectURL(selectedFile)
      setPreview(objectUrl)

      // free memory when ever this component is unmounted
      return () => URL.revokeObjectURL(objectUrl)
  }, [selectedFile])

  const onSelectFile = e => {
      if (!e.target.files || e.target.files.length === 0) {
          setSelectedFile(undefined)
          return
      }

      // I've kept this example simple by using the first image instead of multiple
      setSelectedFile(e.target.files[0])
  }

  const sendImage = () => {
    if (!selectedFile) {
      console.log("no file selected");
      return;
    }
    var file = document.getElementById("image-input").files[0];
    var reader = new FileReader();

    const Http = new XMLHttpRequest();
    const url='http://localhost:6969/image/' + selectedFile.name;
    console.log("configured a request to " + url);

    reader.onloadend = function() {
      console.log("sending", reader.result)
      Http.open("POST", url, false);  // true for async image sending
      Http.setRequestHeader('content-type', 'application/x-www-form-urlencoded;charset=UTF-8');
      Http.send("picture=" + reader.result.toString());
    }
    reader.readAsDataURL(file);
    
    Http.onreadystatechange = () => {
      console.log(Http.responseText)
    }
  }

  return (
     <Layout>
    <div className="container text-center my-5">
      <h1> Start</h1>
      <p> To start the process and save energy, upload the image of your floorplan here.</p>
      
      <input className="form-control" type ="file" id="image-input" accept="image/jpeg, image/png, image/jpg"  onChange={onSelectFile}/>
      {selectedFile &&  <img src={preview} height={600} alt ={"uploaded building plan"}/> }
      <div className="row">
        <Link to="/statistics/" className="btn btn-primary my-2" onClick={sendImage}>Continue</Link>
        <Link to="/" className="btn btn-secondary my-2">Home</Link>
      </div>
    </div>
  </Layout>
  )
}


export default Start

export const Head = () => (
    <Seo title="Start" />
)
 