import * as React from "react"
import { Link } from "gatsby"
import { StaticImage } from "gatsby-plugin-image"

import Layout from "../components/layout"
import {Seo} from "../components/seo"

function show_image(src, alt) {
  var img = document.createElement("img");
  img.src = src;
  img.alt = alt;

  var br = document.createElement("br");
  // This next line will just add it to the <body> tag
  document.body.append(img, br);
}

const Verification = () => (
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

      <div className="row">
        <Link to="/model/" className="btn btn-primary my-2">Create my thermal model</Link>
        <button class="next-page-button" 
        // onclick={show_image('../images/icon.png', "show connectivity")}
        >Show connectivity</button>
      </div>
    </div>
  </Layout>

)

export default Verification



export const Head = () => (
    <Seo title="Verification" />
)

