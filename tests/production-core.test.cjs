const {test}=require('node:test'),assert=require('node:assert/strict'),C=require('../production-core.js');
const doc=(overrides={})=>({executed:true,confirmed:true,items:[{date:'2026-10-09',client:'Arcadis/PWN',project:'PB-1',kind:'Peilbuizen geplaatst',unit:'st',quantity:'3'}],...overrides});
test('alleen bevestigde uitgevoerde bonnen en juiste periode tellen',()=>{
 const a=doc(),b=doc({confirmed:false}),c=doc({executed:false}),d=doc({excluded:true}),e=doc();e.items[0].date='2025-10-09';
 assert.equal(C.totals([a,b,c,d,e],2026).sums['Peilbuizen geplaatst|st'],3);
 assert.deepEqual(C.totals([a],2026,'Sweco').sums,{});
});
test('ontbrekende en ongeldige hoeveelheden/datum niet als nul tellen',()=>{for(const q of ['', 'onbekend','1,5']){const d=doc();d.items[0].quantity=q;assert.ok(C.errors(d).length);}assert.equal(C.validDate('2026-02-30'),false);});
test('credits en Nederlandse decimalen',()=>{assert.equal(C.number('1.250,50'),1250.5);const d=doc();d.items[0].quantity='-1';assert.equal(C.totals([d],2026).sums['Peilbuizen geplaatst|st'],-1);});
test('suggesties geen diameter/diepte of bemonstering als productie',()=>{
 const a=C.suggestions(['Projectnummer: PB-1\nPeilbuis plaatsen 3 st\nStraatpot 2 st\nBoren 25,5 m\nBemonsteren peilbuis 10 st\nBoordiepte 175 m\nPeilbuis diameter 32 mm']);
 assert.equal(a.length,3);assert.deepEqual(a.map(x=>x.quantity),['3','2','25.5']);assert.equal(a[0].project,'PB-1');assert.equal(a[0].date,'');
});
test('meerdere getallen met eenheid blijven handmatige controle',()=>{assert.equal(C.suggestions(['Peilbuis plaatsen 2 st en 3 st'])[0].quantity,'');});
