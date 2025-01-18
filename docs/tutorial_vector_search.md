
## AIGraph4pg Tutorial : Vector Search

##### Coming Soon: Advanced Vector Search with DiskANN and Semantic Ranking

This reference application does not yet implement vector search with DiskANN,
and augmented with Semantic Ranking. This functionality is expected to be
added to this project in January/February 2025.[DiskANN](https://www.microsoft.com/en-us/research/project/project-akupara-approximate-nearest-neighbor-search-for-large-scale-semantic-search/) is a set of advanced algorithms for vector search and semantic ranking developed by
Microsoft Research. It enables high-scalability, high-performance as well as lower costs.DiskANN is being integrated into several Microsoft products.
It is currently available in preview mode for
[Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-use-pgdiskann).[Semantic Ranking](https://techcommunity.microsoft.com/blog/adforpostgresql/introducing-the-semantic-ranking-solution-for-azure-database-for-postgresql/4298781) functionality is also being integrated into Azure Database for PostgreSQL.
It can be used to improve vector search result quality by using semantic ranking models
to rerank vector search results.

---

##### Vector Search Concepts

[Vector Search](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-use-pgvector#concepts) is the functionality in modern databases to search by the
**semantic meaning** of data rather than just precice or fuzzy value matching.
Vector search is typically used in Generative AI applications, where RAG data
is passed to a Large Language Model (LLM) to augment the knowledge base of the model.
Vector search is used to identify this RAG data to be passed to the LLM.Vector search works by first **"vectorizing"** your text data, such as a
product description or summary or a legal case. To create a vector, you invoke an
optimized model in the LLM and pass in your text data to be vectorized. The LLM responds
with a vector of floating-point values of n-dimensions that represents the semantic meaning
of your text data. A vector is alternatively called an **embedding**.You then populate this vector data in your database, and index it with a vector index
so as to make it searchable.To query your database using vector search, you pass in a vector of floating-point values
as a search parameter. You will often have to generate this vector at runtime, by calling
the same LLM text embedding model, given the user natural language query.
Some databases, including Azure Database for PostgreSQL, support
**filtered vector search**, meaning a search that uses both traditonal
WHERE clause logic as well as vector search logic.

---

##### Vector Search Implementation in this Reference Application with pg\_vector

This initial implementation of this reference application uses the
[pgvector](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-use-pgvector#vector-operators) open-source PostgreSQL extension. Please visit this linked page as it provides
excellent documentation and examples.As described in the
[Quick Start](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-use-pgvector#vector-operators) documentation in this repo, you have to first enable this extension
in your Azure Database for PostgreSQL server.You'll need a database table with a column of type **vector** to store your
vectors/embeddings. The DDL for the legal\_cases table in this project is shown below.
Note the presence of the **embedding** column of type **vector(1536)**.
```

CREATE TABLE legal_cases (
  id                   bigserial primary key,
  name                 VARCHAR(1024),
  name_abbreviation    VARCHAR(1024),
  case_url             VARCHAR(1024),
  decision_date        DATE,
  court_name           VARCHAR(1024),
  citation_count       INTEGER,
  text_data            TEXT,
  json_data            JSONB,
  embedding            vector(1536)      
);
  
```
This vector(1536) column is populated with embeddings produced by the Azure OpenAI
[text-embedding-ada-002](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models?tabs=global-standard%2Cstandard-chat-completions#embeddings) model. This model produces 1536-dimensional embeddings,
meaning it returns an array of 1536 floating-point values.
Therefore, the corresponding PostgreSQL column type is **vector(1536)**.To enable the vector column to be queried efficiently, you need to create an
[index](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-optimize-performance-pgvector#indexing) for the column. There are three supported index types:

* Inverted File with Flat Compression (IVVFlat)
* Hierarchical Navigable Small Worlds (HNSW)
* Disk Approximate Nearest Neighbor (DiskANN)

This reference application uses the **IVFFlat** index type.
The DDL for this index in the legal\_cases table is shown below:
```

DROP INDEX IF EXISTS idx_legal_cases_ivfflat_embedding;
CREATE INDEX idx_legal_cases_ivfflat_embedding
ON     legal_cases
USING  ivfflat (embedding vector_cosine_ops)
WITH  (lists = 50);
  
```
Once the data is populated and the column indexed, you can now execute
a vector search vs that column with the **"embedding <->"** SQL syntax.
Please see the web application code in this repository, file python/webapp.py,
where the vector search SQL is created in method "legal\_cases\_vector\_search\_sql()"
as shown below:
```

def legal_cases_vector_search_sql(embeddings, limit=10):
    return (
        """
select id, name_abbreviation, to_char(decision_date, 'YYYY-MM-DD')
 from legal_cases
 order by embedding <-> '{}'
 offset 0 limit 10;
    """.format(
            embeddings
        )
        .replace("\n", " ")
        .strip()
    )
  
```
This query returns the legal case name abbreviation and the date of
the legal case decision for the 10 legal cases that are most similar
to the given embedding value. This is very powerful search functionality.
