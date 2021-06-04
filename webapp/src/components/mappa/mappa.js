import axios from 'axios'
import ECharts from 'vue-echarts'
// import 'echarts/lib/chart/line'
// import 'echarts/lib/chart/bar'
import 'echarts/lib/chart/pie'
import 'echarts/lib/component/legend'
import 'echarts/lib/component/title'
import 'echarts/lib/component/tooltip'

export default {
  name: 'mappa',
  components: {
    'echarts': ECharts
  },
  props: [],
  data () {
    return {
      sWSBackend: '',
      isReloading: false, // re-bucketing graph data
      sampleCount: [],
      sampleInfo: [],
      maxRows: 100,
      alfa: '',
      gamma: '',
      totale: 0,
      chartRegioniNumQuote: {
        title: [{
          text: 'Quote',
          subtext: 'Distribuzione delle quote per Regione',
          left: '30%',
          textAlign: 'center'
        }, {
          text: 'Valore - v1',
          subtext: 'Distribuzione del valore V1 per Regione',
          left: '70%',
          textAlign: 'center'
        }],
        tooltip: {
          trigger: 'item'
        },
        // legend: {
        //   orient: 'vertical',
        //   left: 'left'
        // },
        series: [
          {
            name: 'Num. Quote',
            type: 'pie',
            radius: '50%',
            center: ['30%', '45%'],
            tooltip: {
              formatter: (p) => {
                let label = p.value
                return new Intl.NumberFormat('it-IT').format(label)
              }
            },
            data: [],
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          },
          {
            name: 'Val. Totale Quote',
            type: 'pie',
            radius: '50%',
            center: ['70%', '45%'],
            tooltip: {
              formatter: (p) => {
                let label = p.value
                return new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(label)
              }
            },
            data: [],
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]

      }
    }
  },
  computed: {
  },
  mounted () {
    console.log('Mounted....')
    this.sWSBackend = process.env.VUE_APP_WS_BACKEND
    console.log("Avvio l'APP puntanto i WS a: [" + this.sWSBackend + ']')

    this.fetchData()
  },
  methods: {
    'dummy': function () {
      console.log('[dummy] here I am...')
    },
    // fetchData legge il file JSON e prepara le strutture dati
    'fetchData': async function () {
      let url = 'out.json'
      if (process.env.NODE_ENV === 'production') {
        url = '/ANALISI_FONDI_5x1000/out.json'
      } else {
        url = '/out.json'
      }
      let response = await axios.get(url)
      console.log('[fetchData] recuperati [' + response.data.length + '] record....')

      // strutture temporanee dove accumulo i dati per il grafico
      let regioniQuote = {}
      let regioniValori = {}

      // ricordiamoci che un record è fatto cosi':
      // {"id": 10,"piva": "95051730109","ragione_sociale": "FONDAZIONE ITALIANA SCLEROSI MULTIPLA ONLUS","regione": "LIGURIA","provincia": "GE","citta": "GENOVA","num_quote": 124542,"v1": 3603796.27,"v2": 1495908.31,"v3": 5099704.58}

      // looppo i dati nel file e alimento le strutture temporanee
      response.data.forEach((rec) => {
        if (typeof regioniQuote[rec.regione] === 'undefined') {
          regioniQuote[rec.regione] = rec.num_quote
        } else {
          regioniQuote[rec.regione] += rec.num_quote
        }

        if (typeof regioniValori[rec.regione] === 'undefined') {
          regioniValori[rec.regione] = rec.v1
        } else {
          regioniValori[rec.regione] += rec.v1
        }
      })

      // popolo la serie
      Object.keys(regioniQuote).forEach((r) => {
        this.chartRegioniNumQuote.series[0].data.push({ 'name': r, 'value': regioniQuote[r] })
        this.chartRegioniNumQuote.series[1].data.push({ 'name': r, 'value': regioniValori[r] })
      })

      console.log(regioniQuote)
      console.log(regioniValori)
    }
  }
}
