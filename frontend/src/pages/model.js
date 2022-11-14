import * as React from "react"
import { Link } from "gatsby"
import { StaticImage } from "gatsby-plugin-image"

import Layout from "../components/layout"
import {Seo} from "../components/seo"


function show_image(src, width, height, alt) {
  var img = document.createElement("img");
  img.src = src;
  img.width = width;
  img.height = height;
  img.alt = alt;

  var br = document.createElement("br");
  // This next line will just add it to the <body> tag
  document.body.append(img, br);
}


const Model = () => (
  <Layout>
    <div className="container text-center my-5">
      <h1> Result</h1>
      <p> Here is a simulation of your model!</p>
      <StaticImage
            src="../images/mockUpModelPlot.png"
            width={500}
            quality={95}
            formats={["AUTO", "WEBP"]}
            alt="A Gatsby astronaut"
            className="img-fluid"
          />

      <div className="row">
        <Link to="/start/" className="btn btn-primary my-2">Back to homepage</Link>
      </div>
    </div>
  </Layout>

)

export default Model



export const Head = () => (
    <Seo title="Model" />
)

