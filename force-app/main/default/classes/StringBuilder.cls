public virtual with sharing class StringBuilder
{
	protected String m_stringValue;
	
	public StringBuilder() {}

    public StringBuilder(String value) 
    {
        add(value);
    }

	public virtual void add(String value)
	{
		m_stringValue = ( m_stringValue==null ? value : m_stringValue + value );
	}

	public virtual String getStringValue()
	{
		return m_stringValue;
	}
}