import { LightningElement, api, track, wire } from "lwc";
import getVoos from "@salesforce/apex/VoosService.getVoos";

export default class VoosAndamentoMap extends LightningElement {
  @api recordId;
  @track map;
  @track accountId = null;
  @track locais;
  @track prefixo;
  @track showMap;
  @track voo;

  @track helicopterMarker;
  @track heliIcon;

  @track openMap = false;

  get utilityMapIcon() {
    return !this.openMap ? 'utility:expand' : 'utility:contract';
  }

  get nomePrefixoFormatado() {
    return this.prefixo ? this.prefixo.Name.replace('-', '') : '';
  }

  get iframeUrl() {
    return `https://www.flightradar24.com/simple?callsign=${this.nomePrefixoFormatado}&solo=1`;
  }

  handleMap() {
    let mapContainer = this.template.querySelector('.map-container');
    let iframe = this.template.querySelector('.frame');

    if (!this.openMap) {
      mapContainer.style.width = 'calc(100vw - 1rem)';
      mapContainer.style.height = '100vh';
      mapContainer.style.position = 'fixed';
      mapContainer.style.zIndex = '1000';
      mapContainer.style.top = '0';
      mapContainer.style.left = '0';
      mapContainer.style.padding = '0';
      mapContainer.style.margin = '0';
      iframe.style.width = '100vw';
      iframe.style.height = '100vh';
    } else {
      mapContainer.style.width = '100%';
      mapContainer.style.height = 'auto';
      mapContainer.style.position = 'relative';
      mapContainer.style.zIndex = '0';
      mapContainer.style.top = '0';
      mapContainer.style.left = '0';
      mapContainer.style.paddingTop = '1rem';
      mapContainer.style.margin = '0';
      iframe.style.width = '100%';
      iframe.style.height = '60vh';
    }
    this.openMap = !this.openMap;
  }
  connectedCallback() {
    getVoos({
      voosId: [this.recordId]
    })
      .then((voos) => {
        this.voo = voos[0];
        if (this.voo.Status__c === "Rota") {
          this.prefixo = this.voo.Prefixo__r;
          this.showMap = true;
          //   Promise.all([
          //     loadScript(this, leaflet + "/leaflet.js"),
          //     loadStyle(this, leaflet + "/leaflet.css")
          //   ])
          //     .then(() => {
          //       this.initializeleaflet();
          //     })
          //     .catch((error) => {
          //       console.error(error);
          //       this.dispatchEvent(
          //         new ShowToastEvent({
          //           title: "Erro ao carregar leaflet",
          //           message: error,
          //           variant: "error"
          //         })
          //       );
          //     });
        }
      })
      .catch((error) => {
        console.error(error);
      });
  }

  // updatePrefixo() {
  //   setInterval(() => {
  //     getPrefixos({
  //       prefixosId: [this.prefixo.Id]
  //     })
  //       .then((prefixos) => {
  //         this.prefixo = prefixos[0];
  //         this.map.removeLayer(this.helicopterMarker);
  //         this.helicopterMarker = L.marker(
  //           [
  //             this.prefixo.Posicao__Latitude__s,
  //             this.prefixo.Posicao__Longitude__s
  //           ],
  //           {
  //             icon: this.heliIcon
  //           }
  //         ).addTo(this.map);
  //       })
  //       .catch((error) => console.error(error));
  //   }, 30000);
  // }

  // initializeleaflet() {
  //   try {
  //     const mapRoot = this.template.querySelector(".map-root");
  //     this.map = L.map(mapRoot);
  //     this.map.setView(
  //       [this.prefixo.Posicao__Latitude__s, this.prefixo.Posicao__Longitude__s],
  //       7
  //     );

  //     this.heliIcon = L.icon({
  //       iconUrl: helicopterIcon,
  //       //shadowUrl: 'leaf-shadow.png',

  //       iconSize: [59, 19], // size of the icon
  //       //shadowSize:   [50, 64], // size of the shadow
  //       iconAnchor: [30, 8], // point of the icon which will correspond to marker's location
  //       //shadowAnchor: [4, 62],  // the same for the shadow
  //       popupAnchor: [-3, -76] // point from which the popup should open relative to the iconAnchor
  //     });

  //     this.helicopterMarker = L.marker(
  //       [this.prefixo.Posicao__Latitude__s, this.prefixo.Posicao__Longitude__s],
  //       {
  //         icon: this.heliIcon
  //       }
  //     ).addTo(this.map);

  //     let locais = {};
  //     for (let trecho of this.voo.Trechos__r) {
  //       locais[trecho.Origem__r.Id] = trecho.Origem__r;
  //       locais[trecho.Destino__r.Id] = trecho.Destino__r;
  //     }

  //     for (let localId of Object.keys(locais)) {
  //       let local = locais[localId];
  //       L.marker([
  //         local.Coordenadas__Latitude__s,
  //         local.Coordenadas__Longitude__s
  //       ])
  //         .addTo(this.map)
  //         .bindPopup(local.Name);
  //     }

  //     this.updatePrefixo();

  //     L.tileLayer(
  //       "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
  //       {
  //         attribution:
  //           '&copy; Map tiles by Carto, under CC BY 3.0. Data by <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>, under ODbL.'
  //       }
  //     ).addTo(this.map);
  //     mapRoot.style.position = 'sticky';
  //   } catch (error) {
  //     console.error(error);
  //   }
  // }
}