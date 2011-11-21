package pbblog;

import java.util.EmptyStackException;
import java.util.HashMap;
import javax.xml.namespace.QName;


/**
 * <p>
 * This is a utility for a SAX <code>ContentHandler</code> implementation to use in
 * tracking namespace declarations during a parse.  The assumption is that the
 * handler has access to the full stream of events relevant to managing the
 * declarations.  The primary use case is the resolution of <code>String</code>s, 
 * e.g., from attribute values or element content, to <code>QName</code> objects.
 * </p>
 */
public class NamespaceStack {

  private Frame _current;
  
  /**
   * <p>
   * Construct a new instance with the bare minimum bindings for the
   * <code>xmlns</code>, <code>xml</code>, and empty prefixes.  Note that the empty
   * prefix is bound to the empty (non-<code>null</code>) URI.
   * </p>
   */
  public NamespaceStack() {
    _current = new Frame();
    /*
     * As per the Namespaces in XML Errata:
     * http://www.w3.org/XML/xml-names-19990114-errata
     */
    _current.declarePrefix("xmlns","http://www.w3.org/2000/xmlns/");
    /*
     * As per the Namespaces in XML Rec:
     * http://www.w3.org/TR/1999/REC-xml-names-19990114
     */
    _current.declarePrefix("xml","http://www.w3.org/XML/1998/namespace");
    /*
     * As per the Namespaces in XML Rec:
     * http://www.w3.org/TR/1999/REC-xml-names-19990114
     */
    _current.declarePrefix("","");
  }
  
  /**
   * <p>
   * Push a fresh context onto the stack.  This method should be called somewhere in
   * the body of a <code>startElement()</code>, as it represents the namespace
   * resolution context for the events that occur between that event and the
   * corresponding <code>endElement()</code>.
   * </p>
   * @see org.xml.sax.ContentHandler
   */
  public void pushNewContext() {
    _current = new Frame(_current);
  }
  
  /**
   * <p>
   * Pop a context from the stack.  This method should be called somewhere in the
   * body of an <code>endElement</code>, as it clears the context that was used for
   * namespace resolution within the body of the corresponding element.
   * </p>
   * @see org.xml.sax.ContentHandler
   */
  public void pop() {
    if (_current._parent == null) {
      throw new EmptyStackException();
    }
    _current = _current._parent;
  }
  
  /**
   * <p>
   * Declare a new prefix binding.  This binding will supercede a binding with the
   * same prefix in the same scope.  As a crutch, <code>null</code> arguments may be
   * passed and will be interpreted as <code>&quot;&quot;</code>.  Note that binding
   * a non-empty prefix to an empty URI is not permitted in XML 1.0 but is not
   * flagged as an error by the method.
   * </p>
   * @param prefix the prefix to bind
   * @param uri the URI to bind it to
   */
  public void declarePrefix(String prefix, String uri) {
    _current.declarePrefix(prefix==null?"":prefix, uri==null?"":uri);
  }
  
  /**
   * <p>
   * Retrieve the URI bound to the supplied prefix or <code>null</code> if no URI
   * is bound to the supplied prefix.  As a crutch, a <code>null</code> argument
   * may be passed and will be interpreted as the empty prefix
   * (<code>&quot;&quot;</code>).
   * </p>
   * @returns the URI or <code>null</code> if no URI is bound.
   */
  public String getNamespaceUri(String prefix) {
    return _current.getNamespaceURI(prefix==null?"":prefix);
  }
  
  /**
   * <p>
   * Derference the prefix on a QName in <code>String</code> form and return a Java
   * <code>QName</code> object.
   * </p>
   * @param qname the QName in string form.
   * @return the dereferenced <code>QName</code>.
   * @throws IllegalArgumentException if a <code>null</code> argument is passed,
   * a malformed argument (e.g., <code>:foo</code> or <code>foo:</code>) is passed,
   * or if the prefix cannot be resolved to a URI.
   */
  public QName dereferenceQName(String qname) {
    if (qname == null) {
      throw new IllegalArgumentException("Unable to dereference <null> as a QName.");
    }
    int pos = qname.indexOf(':');
    QName qn;
    if (pos == qname.length() - 1 || pos == 0) {
      throw new IllegalArgumentException("\"" + qname + "\" is a malformed QName.");
    } else if (pos == -1) {
      qn = new QName (getNamespaceUri(""),qname);
    } else {
      String uri = getNamespaceUri(qname.substring(0,pos));
      if (uri == null) {
        throw new IllegalArgumentException("No URI is bound to " +
            qname.substring(0,pos) + ".");
      }
      qn = new QName(uri,qname.substring(pos+1));
    }
    return qn;
  }
  
  private class Frame {
    
    Frame _parent;
    
    HashMap/*<String,String>*/ _bindings;
    
    Frame() {
      // This space intentionally left blank.
    }
    
    Frame(Frame parent) {
      _parent = parent;
    }
    
    void declarePrefix(String prefix, String uri) {
      if (_bindings == null) {
        _bindings = new HashMap();
      }
      _bindings.put(prefix,uri);
    }
    
    String getNamespaceURI(String prefix) {
      String uri = null;
      if (_bindings != null) {
        uri = (String)_bindings.get(prefix);
      }
      if (uri == null) {
        uri= _parent==null?null:(_parent.getNamespaceURI(prefix));
      }
      return uri;
    }
    
  }
}
