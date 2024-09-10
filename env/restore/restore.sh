docker run --name neo4j -d \
     -v ./neo4j/data:/data \
     -v ./dump:/var/lib/neo4j/import \
     -p 7474:7474 -p 7687:7687 \
     neo4j:4.4

docker stop neo4j

docker run --rm \
     --volume ./neo4j/data:/data \
     --volume ./dump:/var/lib/neo4j/import \
     neo4j:4.4 \
     neo4j-admin load \
     --from=/var/lib/neo4j/import/neo4j_wikipedia_graph.dump \
     --database=neo4j --force

docker start neo4j # neo4j default password
