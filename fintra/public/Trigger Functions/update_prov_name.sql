--Function que llama el trigger
CREATE OR REPLACE FUNCTION update_prov() RETURNS trigger AS
$$
BEGIN
	
   	update proveedor 
   	set payment_name = new.nombre
   	where nit = new.cedula;
	RETURN NEW;    -- retruning NULL would mean that the row won't be inserted!
END;
$$
LANGUAGE plpgsql;



--Trigger
CREATE TRIGGER update_prov_name after UPDATE ON nit 
FOR EACH ROW
EXECUTE PROCEDURE update_prov();

