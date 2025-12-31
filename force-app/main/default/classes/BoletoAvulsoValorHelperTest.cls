/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BoletoAvulsoValorHelper      100%                                 *
**************************************************************************/
@isTest
public class BoletoAvulsoValorHelperTest {

    // numero inteiro < que valor minimo
    @isTest
    public static void NumIntMenorQueMinTest(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1.00', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isFalse(output[0].valorValido, 'O valor deve ser inválido pois é menor que o valor mínimo');
    }

    // numero decimal com , e menor que valor minimo e uma casa decimal
    @isTest
    public static void NumDecimalMenorQueMinComVirgulaTest(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1,5';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1.50', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isFalse(output[0].valorValido, 'O valor deve ser inválido pois é menor que o valor mínimo');
    }

    // numero decimal com , e menor que valor minimo e duas casas decimal
    @isTest
    public static void NumDecimalDuasCasasMenorQueMinComVirgulaTest(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1,55';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1.55', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isFalse(output[0].valorValido, 'O valor deve ser inválido pois é menor que o valor mínimo');
    }

    // decimal com . e menor que valor mínimo
    @isTest
    public static void NumDecimalMenorQueMinComPontoTest(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1.55';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1.55', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isFalse(output[0].valorValido, 'O valor deve ser inválido pois é menor que o valor mínimo');
    }

    
    // valor valido separado por . e , test
    @isTest
    public static void valorValidoComVirgulaTest(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1.350,09';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1350.09', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // valor valido separado por , 
    @isTest
    public static void valorValidoComVirgulasTest(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1,350,09';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1350.09', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // valor valido separado por .
    @isTest
    public static void valorValidoComPontosTest(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1.350.09';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1350.09', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // Valor válido dezena e unidade
    @isTest
    public static void valorValidoNumeroInteiroDezena(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = '25';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('25.00', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // Valor válido centena
    @isTest
    public static void valorValidoNumeroInteiroCentena(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = '325';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('325.00', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // Valor válido milhar
    @isTest
    public static void valorValidoNumeroInteiroMilhar(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = 'R$ 1376';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('1376.00', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // Valor válido milhares
    @isTest
    public static void valorValidoNumeroInteiroMilhares(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = '10350';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('10350.00', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // Valor válido milhares
    @isTest
    public static void valorValidoValorFormatado(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = '10.350,00';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('10350.00', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isTrue(output[0].valorValido, 'O valor é válido');
    }

    // Valor inválido maior que máximo 
    @isTest
    public static void valorMaiorQueMaximo(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = '20.000';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.areEqual('20000.00', output[0].valor, 'O valor retornado deve ser uma string em formato decimal');
        Assert.isFalse(output[0].valorValido, 'O valor é invalido pois é maior que o valor maximo');
    }

    // Valor invalido erro de digitação
    @isTest
    public static void valorInvalidoErroDigitacao(){
        List<BoletoAvulsoValorHelper.InputValor> inputs = new List<BoletoAvulsoValorHelper.InputValor>();
        BoletoAvulsoValorHelper.InputValor input = new BoletoAvulsoValorHelper.InputValor();
        input.valor = '1,1,1,1,1';
        input.valorMinimo = '10';
        input.valorMaximo =  '10485.1';
        inputs.add(input);

        Test.startTest();
        List<BoletoAvulsoValorHelper.OutputValor> output = BoletoAvulsoValorHelper.validarValorValor(inputs);
        Test.stopTest();

        Assert.isNull(output[0].valor, 'O valor não deve ser retornado pois houve erro na digitação');
        Assert.isFalse(output[0].valorValido, 'O valor é invalido pois houve erro na digitação');
    }
}