import * as React from "react"
import { Link } from "gatsby"
import { StaticImage } from "gatsby-plugin-image"
import { useState, useEffect} from 'react'

import Layout from "../components/layout"
import {Seo} from "../components/seo"

//https://stackoverflow.com/questions/70679860/trying-to-display-an-photo-when-button-is-clicked-reactjs

function Verification () {
  const [isImageActive, setIsImageActive] = useState(false);
  function clickEventHandler() {
    setIsImageActive(true);
  }

    return (
      <Layout>
      <div className="container text-center my-5">
        <h1> Bounding Boxes</h1>
        <p> Here is a result for the recognition of the rooms of your building:</p>
        <StaticImage
              src="../images/labels_cropped.png"
              width={500}
              quality={95}
              formats={["AUTO", "WEBP"]}
              alt="labeled floor plan"
              className="img-fluid"
            />
         {isImageActive && (
              <StaticImage
              src="../images/graph.svg"
              height={1000}
              quality={95}
              formats={["AUTO", "WEBP"]}
              alt="labeled floor plan"
              className="img-fluid"
            />
           )}
        <div className="row">
          <Link to="/model/" className="btn btn-primary my-2">Create my thermal model</Link>
          <button onClick={clickEventHandler}>Show connectivity graph</button>
           
        </div>
      </div>
     </Layout>
    );
}


export default Verification;

export const Head = () => (
    <Seo title="Verification" />
)

