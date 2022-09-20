create or replace package body pljson_object_cache as

  /* E.I.Sarmas (github.com/dsnz)   2020-04-18   object cache to speed up internal operations */

  /* !!! NOTE: this package is used internally by pljson and it's not part of the api !!! */

  procedure set_names_set(names pljson_varray) is
  begin
    if names.COUNT = 0 then
      return;
    end if;
    for i in names.FIRST .. names.LAST loop
      names_set(names(i)) := '1';
    end loop;
  end;

  function in_names_set(a_name varchar2) return boolean is
  begin
    if names_set.exists(a_name) then
      return true;
    else
      return false;
    end if;
  end;

  procedure reset is
  begin
    last_id := 0;
    flush;
  end;

  procedure flush is
  begin
    pljson_element_cache.delete;
    cache_reqs := 0;
    cache_hits := 0;
    cache_invalid_reqs := 0;
  end;

  procedure print_stats is
  begin
    dbms_output.put_line('reqs = ' || cache_reqs);
    dbms_output.put_line('hits = ' || cache_hits);
    dbms_output.put_line('invalid reqs = ' || cache_invalid_reqs);
    dbms_output.put_line('cache count = ' || pljson_element_cache.count);
    dbms_output.put_line('id count = ' || last_id);
  end;

  function next_id return number is
  begin
    last_id := last_id + 1;
    return last_id;
  end;

  function object_key(elem pljson_element, piece varchar2) return varchar2 is
    key varchar2(250);
  begin
    if elem.object_id is null or elem.object_id = 0 then
      cache_invalid_reqs := cache_invalid_reqs + 1;
      return null;
    end if;
    key := to_char(elem.object_id)||'.'||piece;
    return key;
  end;

  function get(key varchar2) return pljson_element is
    cache_key varchar2(32767);
  begin
    cache_key := key;
    if cache_key is null then
      cache_key := '$';
    end if;
    cache_reqs := cache_reqs + 1;
    if pljson_element_cache.exists(cache_key) then
      cache_hits := cache_hits + 1;
      return pljson_element_cache(cache_key);
    else
      return null;
    end if;
  end;

  procedure set(key varchar2, val pljson_element) is
    cache_key varchar2(32767);
  begin
    cache_key := key;
    if cache_key is null then
      cache_key := '$';
    end if;
    --dbms_output.put_line('caching: ' || cache_key);
    pljson_element_cache(cache_key) := val;
  end;

  /*
  -- experimental, ignore
  -- to use with 'get_json_element'

  function get_piece(elem pljson, piece varchar2) return pljson_element is
    key varchar2(250);
    val pljson_element;
  begin
    key := object_cache.object_key(elem, piece);
    if key is null then
      return elem.get(piece);
    end if;
    val := object_cache.get(key);
    if val is not null then
      return val;
    else
      val := elem.get(piece);
      object_cache.set(key, val);
      return val;
    end if;
  end;

  function get_piece(elem pljson_list, piece varchar2) return pljson_element is
    key varchar2(250);
    val pljson_element;
  begin
    key := object_cache.object_key(elem, piece);
    if key is null then
      return elem.get(piece);
    end if;
    val := object_cache.get(key);
    if val is not null then
      return val;
    else
      val := elem.get(piece);
      object_cache.set(key, val);
      return val;
    end if;
  end;
  */
end;
/
show err