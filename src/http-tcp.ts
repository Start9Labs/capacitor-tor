
// (1) an initial line,
// (2) zero or more header lines,
// (3) a blank line (i.e. a CRLF by itself), and
// (4) an optional message body (e.g. a file, or query data, or query output).


// (1) Initial line...

export type Method = 'OPTIONS' 
                   | 'GET' 
                   | 'HEAD' 
                   | 'POST' // BODY SEMANTICS
                   | 'PUT' // BODY SEMANTICS
                   | 'DELETE' 
                   | 'TRACE' // NO BODY PERMITTED
                   | 'CONNECT'
                   | 'PATCH' // rfc5789, BODY SEMANTICS

function mkPath(p: string): string {
    return p.startsWith('/') ? p : '/' + p
}
function initialText(method: Method, path: string): string {
    return `${method} ${mkPath(path)} HTTP/1.1${CRLF}`
}


// (2) Headers

// HTTP 1.0 defines 16 headers, though none are required. HTTP 1.1 defines 46 headers, and one (Host:) is required in requests.
export type BaseHeaders = { [header: string]: string } & { "Host": string } // header keys are case insensitive, values may be case sensitive
export type Headers<m extends Method> = m extends ('POST' | 'PUT' | 'PATCH') ? BodyHeaders : BaseHeaders

// " The presence of a message-body in a request is signaled by the
//   inclusion of a Content-Length or Transfer-Encoding header field in
//   the request's message-headers. 4.3
// " For compatibility with HTTP/1.0 applications, HTTP/1.1 requests
//   containing a message-body MUST include a valid Content-Length header
//   field unless the server is known to be HTTP/1.1 compliant." 4.4
export type BodyHeaders = BaseHeaders 
    &  { "Content-Length": number     }  // The Content-Length entity-header field indicates the size of the entity-body, in decimal number of OCTETs. 14.13
    &  { "Content-Type"?: string      }  // mime-type
    &  { "Transfer-Encoding"?: string }  // if not identity, then 'chunked' is used to calculate message-length, not content-length. content-length still required?


const CRLF = "\r\n"

// Folding must be performed by calling code (that is, multiline header values must be assembled appropriately by calling code).
// Does not support multiple headers of the same name. (spec allows for this for some reason)
//@TODO validations "i.e., (header keys must have) characters that  have  values  between  33.  and  126., decimal, except colon" RFC#822 3.1.2
//@TODO best practice to have general headers, then request/response headers, then entity headers. 4.2
function headersText<method extends Method>(headers: Headers<method>): string[] {
    return Object.entries(headers).map( ([k,v]) => {
        //"The field value MAY be preceded by any amount of LWS, though a single SP is preferred." 4.2
        //"Such leading or trailing LWS MAY be removed without changing the semantics of the field value." 4.2
        return `${k}: ${v.trim()}${CRLF}` 
    })
}

export function httpToTcpBuf<method extends Method>(
    method: method, 
    path: string, 
    headers: Headers<method>, 
    body: method extends ('POST' | 'PUT' | 'PATCH') ? string : undefined
): string {
    return [].concat(
        initialText(method, path), //1
        headersText(headers), //2
        CRLF, // 3
        body // 4 (if undefined or null, this is removed with the ensuing .join(''))
    ).join('')   
}