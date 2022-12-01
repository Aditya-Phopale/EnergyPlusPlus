import * as React from "react"
import { Link } from "gatsby"

import Layout from "../components/layout"
import {Seo} from "../components/seo"
import { StaticImage } from "gatsby-plugin-image"

const AboutPage = () => (
  <Layout>
    <div className="container  my-5">

      <div className="container my-5">
        <h1>Do you want to save energy?</h1>
        <p><b>Saving energy</b> is a very important topic, especially in this energy crisis and with climate change. It also very helpful to save money. 
         Apart from using our product there are many ways to further save energy. Here we collected a few resources and advices to inspire you:</p> 
        <u1>
            <li> <a href="https://www.energysage.com/energy-efficiency/101/ways-to-save-energy/">Energysage</a> </li>  
            <li> <a href="https://energysavingtrust.org.uk/hub/quick-tips-to-save-energy/">Energy saving trust</a>  </li>
        </u1> 
        <p></p>
        <p>Our product provides an automatic optimized control of your heating system. Go back to the <Link to="/">homepage</Link> to get started!</p>
      </div>
      
      <div className="container text-center my-5">
          <StaticImage
            src="../images/icon.png"
            width={300}
            quality={95}
            formats={["AUTO", "WEBP"]}
            alt="energy saving"
            className="img-fluid"
          />
      </div>


      <div className="container my-5">
        <h1 >This is our solution</h1>
        
          <p>Operations efficiency could be significantly improved by robust control algorithms. 
            Control system would include creating a model, parameter initialization & simulation and a feedback loop.
          </p>
          <p><b>Target: </b>provide automatic means for generation of thermal networks out of building plans as well as estimation of their potential parameters.</p>
          <p><b>Product structure: </b></p>
      </div>

      <div className="container text-center my-5">
          <StaticImage
            src="../images/product_structure.png"
            width={1000}
            quality={100}
            formats={["AUTO", "WEBP"]}
            alt="product structure "
            className="img-fluid"
          />
      </div>

      <div className="container my-5">
        <h1 >... and this is our team!</h1>
        
        <p>The project is a collaboration of <a href="https://www.siemens.com/de/de.html">Siemens AG</a> and the <a href="https://www.bgce.de/">TUM BGCE</a> program. We are a group of students from the <a href="https://www.tum.de">Technical University of Munich</a>, who study <a href = "https://www.tum.de/en/studies/degree-programs/detail/computational-science-and-engineering-cse-master-of-science-msc"> Computational Science and Engineering.</a></p>
        <h3>Student Team:</h3>
        <ul>
          <li>Aditya Phopale</li>
          <li>Andrea De Girolamo</li>
          <li>Elizaveta Boriskova</li>
          <li>Manish Kumar Mishra</li>
          <li>Meike Tütken</li>
          <li>Piyush Karki</li>
        </ul>
        <h3>Project supervisors:</h3>
        <ul>
          <li>Dirk Hartmann, Technical Fellow @ Siemens AG</li>
          <li>Felix Sievers​, PhD Student​ @ Siemens AG</li>
          <li>Friedrich Menhorn, PhD Student @ TUM</li>
        </ul>
      </div>

      <div className="container text-center my-5">
           <StaticImage
            src="../images/team.png"
            width={1000}
            quality={100}
            formats={["AUTO", "WEBP"]}
            alt="this is our team"
            className="img-fluid"
          />
      </div>


    </div>
  </Layout>
)

export default AboutPage

export const Head = () => (
    <Seo title="About" />
)