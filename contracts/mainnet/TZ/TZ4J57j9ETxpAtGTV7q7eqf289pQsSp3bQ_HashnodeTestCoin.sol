//SourceUnit: smart contrac TRON listo.sol

pragma solidity ^0.4.4;

contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 1) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 1) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract HashnodeTestCoin is StandardToken { // CHANGE THIS. Update the contract name.

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    string public version = 'YHWHcore 0.2'; 
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    uint256 public totalSupply;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    address public fundsWallet;           // Where should the raised ETH go?

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function HashnodeTestCoin() {
        balances[msg.sender] = 1102030508013;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 3, set this value to X * 1. (CHANGE THIS)
        totalSupply = 1102030508013;                        // Update total supply (1000 for example) (CHANGE THIS)
        name = "YHWHtoken";                                   // Set the name for display purposes (CHANGE THIS)
        decimals = 3;                                               // Amount of decimals for display purposes (CHANGE THIS)
        symbol = "MAN";                                             // Set the symbol for display purposes (CHANGE THIS)
        unitsOneEthCanBuy = 1;                                      // Set the price of your token for the ICO (CHANGE THIS)
        fundsWallet = msg.sender;                                    // The owner of the contract gets ETH
    }

    function() payable{
        totalSupply = totalSupply+ msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
//YHVH Tokens es un Criptoactivo soberano. Emitido por El Banco de Economía Comunal
//de la Comuna Socialista LA PAZ a través de el ESTADO COMUNAL ABYA YALA, sobre una 
//plataforma de cadena de bloques. El YHWH Tokens criptoactivo emitido para lograr la
//descentralización del sistema Económico Comunal del sistema financiero de los Bancos
//Centrales.
//YHWHcore
//Es una plataforma financiera soportada por una billetera de moneda universal. 
//totalmente respaldado con monedas fiduciarias contenidas en
//reservas complementarias para brindar transparencia a los inversionistas; bajo
//el resguardo de una Institución Financiera y Jurídica. 
//"Consejo Socialista de Economía Comunal, Banco de la Comuna, Comuna Socialista La PAZ. 
//Registro de Información Fiscal: J410244623. Legalmente inscrito en la Oficina de
// Registro Público con Funciones Notariales de los Municipios Obispos y Cruz Paredes 
//del Estado Barinas, bajo el Nº 30, Folios 210 al 223, Protocolo Primero, Tomo Tercero 
//(3º), Principal y Duplicado, Tercer Trimestre del año dos mil diesisiete (2.017).
//República Bolivariana: Venezuela, Estado Comunal ABYA YALA."
//Permitiendo ser completamente transparente en su fundamentación, transformar la 
//forma en que las personas y las empresas almacenan y transfieren valor, pretendiendo 
//facilitar la conversión instantánea y sin problemas de diferentes formas de intercambio
//económico. Dando apertura a la ejecucion y desarrollo de nuestra plataforma de 
//Cripto Activos S.I.E.C., Sistema de Intercambio Economico Comunal. 
//en fucion de la insurgencia del Poder Popular. 
//Reserva de denominaciones o nombres de las discimiles formas de organizaciones
//del Poder Popular de la comunidad Organizada del DISTRITO COMUNAL CAPITAL BARINAS,
//Contituyente de Comunas Agrarias y Socialistas se describe a  continuacion 
//[corchetes con imagen de Garra],establecido en la RESOLUION ES-010 DEL EJE SOCIALISTA,
//Debidamente Protocolizado ante la Oficina del Registro Publico con funciones Notariales 
//bajo el N°03, Folios 18 al 30, Protocolo Primero (1°), Tomo segundo (2°) principal, 
//cuarto trimestre del año dos mil diesiseis. "El simbolo gerarquico entre puntos y corchetes". 
//hacen sintesis de la cadena titulativa de mas de cuatro mil (4.000) Consejo de Base 
//del Poder Popular. Estableciendose a traves de esta cadena titulativa de Bloques 
//la Articulacion de la colectividad en general con la Comision Presidencial INTI-EJE 
//SOCIALISTA LA NUEVA GEOMETRIA DEL PODER. Articulacion de Hecho de Derecho y justicia 
//que preestablece el ambito social y geografico como sistema de agregacion comunal. 
//como consta en Acta de Asamblea de Resolucion ES-003 de fecha 05 de Julio de 2011. 
//en las Oficinas de Registro Publico con Funciones Notariales del Municipio Obispo y 
//Cruz Paredes del Estado Barinas, bajo en N°12, Folios 102 al 105, Protocolo Primero,
//Tomo 2°principal y duplicado, tercer trimestre del año dos mil once.
//se prefigura que las formas de construccion de la supremasia solo seran alcanzadas 
//acelerando el cambio del SISTEMA ECONOMICO, transendiendo el Modelo Rentista Petrolero, 
//al Modelo Economico Productivo, dando paso a una sociedad mas igualitaria y justa, sustentando 
//en rol del Estado Social y Democratico, de derecho y de Justicia, con el fin de seguir avanzando 
//en la plena satisfaccion de las necesidades basicas para la vida de nuestro pueblo: Alimentacion, 
//Agua, Electricidad, Vivienda y habitad, transporte publico, salud, educacion, seguridad publica, 
//acceso a la cultura, la comunicacion, libre, la ciencia y la tegnologia, deporte, la sana recreacion 
//y el trabajo digno liberado y liberador, convertir a VENEZUELA en un Pais potencia en lo Social y Politico
//dentro de la potencia naciente de America Latina y el Caribe, y Garantizar la ejecucion de las zonas de Paz 
//en nuestra America, contribuir el desarrollo de una Nueva GeoEconomia Internacional, en la cual tome 
//cuerpo un Mundo Multicentrico y Pluripolar, que permita lograr ek equilibrio del Universo y
//garantizar la Paz Planetaria. Preservar la vida en el planeta y preservar la Especie Humana, traduciendose 
//en la necesidad de la Ejecucion de un Modelo Economico Productivo ECOSOCIALISTA, Basado en una 
//relacion armonica entre el Hombre y la Naturaleza, y garantizar el uso y aprovechamiento racional y optimo
//de los recursos Naturales, representando los procesos y ciclos de Naturales.
//El avance de nuevas tegnologias dan cabida a la impletacion de sistemas informaticos confiables,
//que permitiran que el proceso de transicion de nuestra sociedad y el del demoscratismo burocratico
//sea mucho mas flexibles, disminuyan las gastos publicos y logren la irrupcion definitiva del estado 
//Burocratista, nuestra plataforma pretende integrar los diferentes sistemas que en la actualidad maneja 
//la administracion publica en Venezuela como plan piloto, por sistemas mas fiable en la utilizacion de Recursos
//Economicos y su distribucion equitativa e igualitaria del mismo, NUestra plataforma impactara positivamente el Medio 
//Ambiente, reduce significativamente el ECOCIDIO, reduce el tiempo de operatividad y conectividad de las
//plataformas bancarias convencionales, reduce el consumo energetico, la obtencion de datos en tiempo real, 
//permite lograr una mejor gestion contralora sobre la utilizacion de recursos publicos colectivos erradicando
//la corruccion, la reduccion de presupuesto en los procesos electorales, debido a la reduccion de consumos 
//de materiales naturales; como papel, plasticos entre otros a 0%, con la implementacion de contratos digitales 
//adaptados que den mayor garantia a los Procesos consultivos. la eliminacion de papeleria contaminante que 
//genera exuberantes sumas de gastos publicos en recoleccion, reciclaje, trasnporte, la erradicacion de procesos
//obsoletos y un paso a la sensibilizacion de los sistemas sociales. 
//att. MARCO ANTONIO NIEVES GARCIA, PIRE COROMOTO AMARU ITATI. Secretario de la Magistratura de Economia Comunal 
//Estado Comunal ABYA YALA.