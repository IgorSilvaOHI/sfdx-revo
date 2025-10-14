import { api } from 'lwc';
import LightningDatatable from "lightning/datatable";
import vooCardTemplate from "./vooCard.html";
import vooImageCardTemplate from "./vooImageCard.html";

export default class MalhaVooDatatable extends LightningDatatable { 

  static customTypes = {
      vooCard: {
        template: vooCardTemplate,
        standardCellLayout: true,
        typeAttributes: ['voo']
      },
      vooImageCard: {
        template: vooImageCardTemplate,
        standardCellLayout: true,
        typeAttributes: ['voo']
      }
  }

  @api
  scrollToPosition(leftVal){

    const container = this.template.querySelector(".slds-scrollable_x");

    container.scrollBy({
      left: leftVal,
      behavior: 'smooth'
    });
  }
}