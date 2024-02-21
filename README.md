<div>  
  <h1>DelphiMVCFramework Paginate Middleware</h2>
  <em>Middleware for paginate results using DelphiMVCFramework</em>
</div>

## Prerequisites

This middleware is designed to work with [Delphi MVC Framework](https://github.com/danieleteti/delphimvcframework).

## Usage

To use this middleware, enable it calling **MVCEngine.AddMiddleware(TMVCPaginateMiddleware.Create)** 

To activate pagination in your response you need to pass a header in your request:

X-Paginate = true;

To controll the paging you can set two params:

limit = X (defines the paging record limit)

page = X (informs which page should be returned)

## Example

**GET** http://127.0.0.1:8080/api/products?page=1&limit=3 

**Response** :

<pre><code>
{
    "results": [
        {
            "id": 1,
            "active": 1,
            "qtd": -12,
            "description": "FRITAS"
        },
        {
            "id": 2,
            "active": 1,
            "qtd": -28,
            "description": "POLENTA"
        },
        {
            "id": 3,
            "active": 1,
            "qtd": -3,
            "description": "CALABRESA + FRITAS"
        }
    ],
    "total": 79,
    "limit": 3,
    "page": 1,
    "pages": 27
}
</code></pre>