
const fs = require('fs');
const graph = JSON.parse(fs.readFileSync('/home/dewald/Workspace/personal/github/zombie_apocalypse/.understand-anything/intermediate/assembled-graph.json', 'utf8'));

let issues = 0;
const nodeIds = new Set(graph.nodes.map(n => n.id));

// Check required node fields
for (const node of graph.nodes) {
  if (!node.id) { console.error('Node missing id'); issues++; }
  if (!node.type) { console.error(`Node ${node.id} missing type`); issues++; }
  if (!node.name) { console.error(`Node ${node.id} missing name`); issues++; }
  if (!node.summary) { console.error(`Node ${node.id} missing summary`); issues++; }
}

// Check edge references
for (const edge of graph.edges) {
  if (!nodeIds.has(edge.source)) { console.error(`Edge source missing: ${edge.source}`); issues++; }
  if (!nodeIds.has(edge.target)) { console.error(`Edge target missing: ${edge.target}`); issues++; }
}

// Check project envelope
if (!graph.project) { console.error('Missing project envelope'); issues++; }
if (!graph.layers || graph.layers.length === 0) { console.error('Missing layers'); issues++; }
if (!graph.tour || graph.tour.length === 0) { console.error('Missing tour'); issues++; }

console.log(`Validation: ${issues} issues found`);
console.log(`Nodes: ${graph.nodes.length}, Edges: ${graph.edges.length}, Layers: ${(graph.layers||[]).length}, Tour: ${(graph.tour||[]).length}`);
process.exit(issues > 0 ? 1 : 0);
