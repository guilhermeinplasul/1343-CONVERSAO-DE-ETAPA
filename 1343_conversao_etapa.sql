/*
  Ticket#64000574 - recalculo do BRF Mono em KM
*/

declare

  
  v_empresa       number(3)           := 1;
  v_produto       varchar2(20)        := '728699';
  v_versao        varchar2(10)        := '70';
  v_unid_origem   varchar2(3)         := 'KM';
  v_unid_destino  varchar2(3)         := 'KM';
  v_p_etapa   pcpetapa.codigo%type    := '42';
  v_p_recurso pcprecurso.codigo%type  := '410';
  /*
  v_empresa       number(3)           := :p_1;
  v_produto       varchar2(20)        := :p_2;
  v_versao        varchar2(10)        := :p_3;
  v_unid_origem   varchar2(3)         := :p_4;
  v_unid_destino  varchar2(3)         := :p_5;
  v_p_etapa   pcpetapa.codigo%type    := :p_6;
  v_p_recurso pcprecurso.codigo%type  := :p_7;*/
  
  v_largura                 number;
  v_largura_emb             number;
  v_altura                  number;
  v_espessura               number;
  v_peso_esp                number;
  valor_largura             number;
  valor_largura_emb         number;
  v_vendedor                number;
  valor_altura              number;
  valor_espessura           number;
  v_tipo_item               number;
  v_espessura_extrusao      number;
  valor_peso_esp            number;
  v_qtde_adesivo            number;
  v_saco                    varchar2(20);
  v_paredes                 number;
  v_pistas                  number;
  v_refile                  number;
  v_peso                    number;
  v_retorno                 number;
  v_tipo_ficha              number;
  v_roteiro                 number;
  valor_espessura_aux       number;
  
  valor_densidade_adesivo   number;
  valor_gramatura_adesivo   number;
  valor_espessura_adesivo   number;
  
  
begin

  --Se a origem da chamada é do cálculo de formação de preços 
  if substr(v_versao,1,2) = 'FP' then
    select  produto into v_produto
      from  fpvfp
      where empresa     = v_empresa
        and sequencial  = replace(v_versao,'FP','');
  end if;
  
  select  tipo_item into v_tipo_item
    from  estitem
    where empresa = v_empresa
      and codigo  = v_produto;
   
  select  count(*) into v_roteiro
    from  pcpetaparoteiro, pcpversao
    where pcpetaparoteiro.empresa = v_empresa
      and pcpetaparoteiro.empresa = pcpversao.empresa
      and pcpetaparoteiro.roteiro = pcpversao.roteiro
      and pcpversao.produto       = v_produto
      and pcpversao.versao        = v_versao
      and pcpetaparoteiro.etapa between 30 and 39;
  
  select  max(largura), max(altura), max(espessura), max(peso_especifico), max(espessura_extrusao), max(largura_embobinamento) 
    into  v_largura, v_altura, v_espessura, v_peso_esp, v_espessura_extrusao, v_largura_emb
    from  pcpatribflex
    where empresa = v_empresa
      and tipo_ficha = (
        select  tipo_ficha
          from  estitem
          where empresa = v_empresa
            and codigo = v_produto
    );
  
  -- Se a origem da chamada é do cálculo de formação de preços 
  if substr(v_versao,1,2) = 'FP' then
  
    valor_largura := replace(nvl(f_busca_valor_fichafp(v_empresa, replace(v_versao,'FP',''), v_largura),0),'.',',');
    valor_altura := replace(nvl(f_busca_valor_fichafp(v_empresa, replace(v_versao,'FP',''), v_altura),0),'.',',');
    valor_espessura := replace(nvl(f_busca_valor_fichafp(v_empresa, replace(v_versao,'FP',''), v_espessura),0),'.',',')*0.0001;
    valor_peso_esp := replace(nvl(f_busca_valor_fichafp(v_empresa, replace(v_versao,'FP',''), v_peso_esp),0),'.',',');
  
  else
  
   if v_tipo_ficha = 1 then
     select max(valor_padrao) into v_saco
       from pcpficha
      where empresa = v_empresa
        and produto = v_produto
        and versao = v_versao
        and atributo = 3; -- 3 APRESENTACAO
        
   else
     select max(valor_padrao) into v_saco
       from pcpficha
      where empresa = v_empresa
        and produto = v_produto
        and versao = v_versao
        and atributo = 105; -- 105 TIPO_PRODUTO
        
    end if;
  
  
    select  max(vendedor) into v_vendedor
      from  cadrepcli
      where empresa = v_empresa
        and cliente in (
        
          select  correntista 
            from  estitemcorr
            where empresa = v_empresa
              and item = v_produto
      );
  
  
    valor_largura:=replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_largura),0),'.',',');
    valor_altura:=replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_altura),0),'.',',');
    
    if v_tipo_item = 2 then
      valor_espessura := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_espessura),0),'.',',')*0.0001;
    
    else
      valor_espessura := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_espessura_extrusao),0),'.',',')*0.0001;
    
    end if;  
      
    valor_peso_esp := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_peso_esp),0),'.',',');
  
  end if;   
  
  
  v_saco := f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 3);
  valor_largura := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_largura),0),'.',',');
  valor_largura_emb := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_largura_emb),0),'.',',');
  valor_altura := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_altura),0),'.',',');
  valor_peso_esp := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_peso_esp),0),'.',',');
  v_paredes := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 41),0),'.',',');
  
  
  if v_tipo_item = 1 then
    v_pistas := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 39),1),'.',',');
  
  else
    v_pistas := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 1536),1),'.',',');
  
  end if;
  
  
  if v_roteiro > 0 then
    if v_tipo_item = 2 then
      valor_espessura := (replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_espessura),0),'.',',')+3)*0.0001;
      valor_espessura_aux := (replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 6139),0),'.',',')+3)*0.0001;
    
    else
      valor_espessura := (replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_espessura_extrusao),0),'.',',')+3)*0.0001;
      valor_espessura_aux := (replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 6139),0),'.',',')+3)*0.0001;
    
    end if;  
  
  
  else
    if v_tipo_item = 1 then
      valor_espessura := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_espessura),0),'.',',')*0.0001;
      valor_espessura_aux := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 6139),0),'.',',')*0.0001;
    
    else
      valor_espessura := replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, v_espessura_extrusao),0),'.',',')*0.0001;
      valor_espessura_aux:=replace(nvl(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 6139),0),'.',',')*0.0001;
    
    end if;  
  
  end if;
  
  v_refile := valor_largura_emb-(v_pistas*(trunc(valor_largura_emb/nvl(v_pistas,1))));
  
  -- cálculo e inclusão de Gramatura
  valor_gramatura_adesivo := nvl(replace(f_busca_valor_ficha(v_empresa, v_produto, v_versao, null, 6146),'.',','),0);
  valor_densidade_adesivo := nvl(replace(f_busca_valor_ficha(v_empresa, '5002596', '1', null, 5159),'.',','),0);
  
  
  if nvl(valor_densidade_adesivo,0) > 0 then
    -- busca espessura com base na gramatura e a densidade
    valor_espessura_adesivo := nvl(valor_gramatura_adesivo/valor_densidade_adesivo,0);
  
  else
    valor_espessura_adesivo := 0;
  
  end if;
  
  valor_espessura := valor_espessura + (valor_espessura_adesivo)*0.0001;
  valor_espessura_aux := valor_espessura_aux + (valor_espessura_adesivo)*0.0001;
  
  
  -- CONVERSAO: de unidade medida de origem para KG
  if v_unid_origem = 'KG' then
    v_peso := 1;
  
  elsif v_unid_origem = 'TON' then
    v_peso := 1000;
  
  elsif v_unid_origem = 'UN' then
    v_peso := valor_largura * valor_altura * valor_espessura * valor_peso_esp / 1000;
  
  elsif v_unid_origem = 'MIL' then
    v_peso := valor_largura * valor_altura * valor_espessura * valor_peso_esp;
  
  elsif v_unid_origem = 'MT' then
  
    if valor_espessura_aux <= valor_espessura then
      v_peso := (valor_largura_emb * valor_espessura_aux * valor_peso_esp / 10)/v_pistas; 
    
    else
      v_peso := (valor_largura_emb * valor_espessura * valor_peso_esp / 10)/v_pistas; 
    
    end if;
    
  elsif v_unid_origem = 'KM' then

    if valor_espessura_aux <= valor_espessura then
      v_peso := 100*((valor_largura_emb * valor_espessura_aux * valor_peso_esp)/v_pistas); 
    
    else
      v_peso := 100*((valor_largura_emb * valor_espessura * valor_peso_esp)/v_pistas); 
    
    end if;      
  
  else
    v_peso := 1;
  
  end if;
  
  
  -- CONVERSAO: de KG para unidade medida de destino
  if v_unid_destino = 'KG' then
    v_retorno := v_peso;
  
  elsif v_unid_destino = 'TON' then
    v_retorno := v_peso / 1000;
  
  elsif v_unid_destino = 'UN' and valor_largura>0 and valor_altura>0 and valor_espessura>0 and valor_peso_esp>0 then
    v_retorno := v_peso / (valor_largura * valor_altura * valor_espessura * valor_peso_esp / 1000);
  
  elsif v_unid_destino = 'MIL' and valor_largura>0 and valor_altura>0 and valor_espessura>0 and valor_peso_esp>0 then
    v_retorno := v_peso / (valor_largura * valor_altura * valor_espessura * valor_peso_esp);
  
  elsif v_unid_destino = 'MT' and valor_largura>0 and valor_espessura>0 and valor_peso_esp>0  and v_paredes > 1 and valor_altura>0 then
    v_retorno := v_peso / ((valor_largura_emb)/v_pistas  * valor_espessura * valor_peso_esp / 10);
  
  elsif v_unid_destino = 'MT' and valor_largura>0 and valor_espessura>0 and valor_espessura <= valor_espessura_aux and valor_peso_esp>0 and valor_espessura_aux >0 then
    v_retorno := v_peso / ((valor_largura_emb)/v_pistas * valor_espessura * valor_peso_esp / 10);
  
  elsif v_unid_destino = 'MT' and valor_largura>0 and valor_espessura>0 and valor_espessura > valor_espessura_aux and valor_peso_esp>0 and valor_espessura_aux>0 then
    v_retorno := v_peso / ((valor_largura_emb)/v_pistas * valor_espessura_aux * valor_peso_esp / 10);
  
  elsif v_unid_destino = 'MT' and valor_largura>0 and valor_espessura>0 and valor_espessura > valor_espessura_aux and valor_peso_esp>0 and valor_espessura_aux=0 then
    v_retorno := v_peso / ((valor_largura_emb)/v_pistas * valor_espessura * valor_peso_esp / 10);
  
  elsif v_unid_destino = 'KM' and valor_largura>0 and valor_espessura>0 and valor_peso_esp>0  and v_paredes > 1 and valor_altura>0 then
    v_retorno := (v_peso / ((valor_largura)  * valor_espessura * valor_peso_esp  / 10))/1000;
  
  elsif v_unid_destino = 'KM' and valor_largura>0 and valor_espessura>0 and valor_espessura < valor_espessura_aux and valor_peso_esp>0 and valor_espessura_aux >0 then
    v_retorno := (v_peso / ((valor_largura) * valor_espessura  * valor_peso_esp / 10))/1000;  -- Atual
    
  elsif v_unid_destino = 'KM' and valor_largura>0 and valor_espessura>0 and valor_espessura >= valor_espessura_aux
        and valor_peso_esp>0 and valor_espessura_aux>0 and v_produto = '728699' then
    v_retorno := (v_peso / (100*((valor_largura_emb * valor_espessura_aux * valor_peso_esp)/v_pistas)));  -- Correção para Ticket#64000574 (teste)
  
  elsif v_unid_destino = 'KM' and valor_largura>0 and valor_espessura>0 and valor_espessura > valor_espessura_aux and valor_peso_esp>0 and valor_espessura_aux>0 then
    v_retorno := (v_peso / ((valor_largura)* valor_espessura_aux * valor_peso_esp / 10))/1000;
    
  elsif v_unid_destino = 'KM' and valor_largura>0 and valor_espessura>0 and valor_espessura > valor_espessura_aux and valor_peso_esp>0 and valor_espessura_aux=0 then
    v_retorno := (v_peso / ((valor_largura) * valor_espessura  * valor_peso_esp / 10))/1000;
  
  else
    v_retorno := v_peso;
  
  end if;
  
  
  dbms_output.put_line('Cálculo alterado:');  
  dbms_output.put_line('v_retorno: ' || v_retorno);
  dbms_output.put_line('v_peso: ' || v_peso);
  dbms_output.put_line('valor_espessura: ' || valor_espessura);
  dbms_output.put_line('valor_espessura_aux: ' || valor_espessura_aux);
  dbms_output.put_line('valor_peso_esp: ' || valor_peso_esp);
  
  
  :p_8 := v_retorno;
   
end;
