import * as React from "react"
import { Link } from "gatsby"
import { useState, useEffect} from 'react'


import Layout from "../components/layout"
import {Seo} from "../components/seo"
import {StaticImage} from "gatsby-plugin-image";

const sendStatistics = e => {
    // send http request to a local server to post values

    // that's how to access them:
    // document.getElementById("outside_thickness");
    // document.getElementById("inside_thickness");
    // document.getElementById("scaling");
}

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
    localStorage.setItem("filename", selectedFile.name);

    const Http = new XMLHttpRequest();
    const url='http://localhost:6969/image/' + selectedFile.name;
    console.log("configured a request to " + url);

    reader.onloadend = function() {
      console.log("sending an image...")
      Http.open("POST", url, true);  // true for async image sending
      Http.send("picture=" + reader.result.toString()); // sending plain-text
    }
    reader.readAsDataURL(file);
    
    Http.onreadystatechange = () => {
      console.log(Http.responseText)
    }
  }

  return (
     <Layout>
    <div className="container text-center my-5">
    <div className="row">
          <div class="col">
              <h2> Upload floor plan </h2>
              <p> To start the process and save energy, upload the image of your floorplan here.</p>

              <input className="form-control" type ="file" id="image-input" accept="image/jpeg, image/png, image/jpg"  onChange={onSelectFile}/>
              {selectedFile &&  <img src={preview} height={600} alt ={"uploaded building plan"}/> }
              <br/>
              <br/>
              <p>Alternatively choose one of these default floorplans:</p>
            {/*  make columns with the different floor plans */}
              <div className="container text-center my-5">
                  <div className="row">
                      <div className="col">
                          <Link to="/model_1" className="btn btn-secondary my-2">Floor plan 1</Link>
                          <StaticImage
                              src="../images/Default_floorplans/floorplan_1.png"
                              width={500}
                              quality={100}
                              formats={["AUTO", "WEBP"]}
                              alt="first default floor plan"
                              className="img-fluid"
                          />
                      </div>
                      <div className="col">
                          <Link to="/model_2" className="btn btn-secondary my-2">Floor plan 2</Link>
                          <StaticImage
                              src="../images/Default_floorplans/floorplan_2.jpeg"
                              width={500}
                              quality={100}
                              formats={["AUTO", "WEBP"]}
                              alt="second default floor plan"
                              className="img-fluid"
                          />
                      </div>
                      <div className="col">
                          <Link to="/model_3" className="btn btn-secondary my-2">Floor plan 3</Link>
                          <StaticImage
                              src="../images/Default_floorplans/floorplan_3.jpeg"
                              width={500}
                              quality={100}
                              formats={["AUTO", "WEBP"]}
                              alt="third default floor plan"
                              className="img-fluid"
                          />
                      </div>
                  </div>
              </div>
            <br/>
            <br/>
         </div>

         <div className="col">
             <h2> Provide floor data </h2>
             <p> Fill in general information: </p>
             <br/>
             <p>
                 <label htmlFor="scaling">Scaling factor of the building plan:</label>
                 <br/>
                 <input
                     type="number"
                     id="scaling"
                     placeholder="1.0"
                     step="0.01"
                     min="0"
                     max="5"
                 ></input>
             </p>
             <p>
                 <label htmlFor="wall thickness">Wall thickness (outside and inside):</label>
                 <br/>
                 <input
                     type="number"
                     id="outside_thickness"
                     placeholder="1.0"
                     step="0.01"
                     min="0"
                     max="5"
                 ></input>
                 <input
                     type="number"
                     id="inside_thickness"
                     placeholder="1.0"
                     step="0.01"
                     min="0"
                     max="5"
                 ></input>
             </p>
              {/*https://www.w3schools.com/tags/tag_select.asp*/}
              <label htmlFor="roof">What is above the floor?</label>
              <br/>
              <select name="roof" id="roof">
                  <option value="roof">A roof</option>
                  <option value="another floor">Another floor</option>
              </select>
             {/*<p>Click on a location on the map to select it (TO BE DONE)</p>*/}
             <br/>
             <br/>
          </div>
    </div>
        <div className="row">
            <Link to="/model/" className="btn btn-primary my-2" onClick={sendImage}>Start the computation</Link>
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
 