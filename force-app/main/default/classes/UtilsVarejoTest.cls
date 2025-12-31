@isTest
public class UtilsVarejoTest {
    @isTest
    public static void validarCPF() {
        FlowValidarDocumento.Input inp = new FlowValidarDocumento.Input();
        inp.documento = '34532826047';

        Test.startTest();
        FlowValidarDocumento.Output result = FlowValidarDocumento.validarDocumento(new List<FlowValidarDocumento.Input>{inp})[0];
        Test.stopTest();

        System.AssertEquals(true, result.cpfValido);
        System.AssertEquals(false, result.cnpjValido);
    }

    @isTest
    public static void validarCNPJ() {
        FlowValidarDocumento.Input inp = new FlowValidarDocumento.Input();
        inp.documento = '72948305000130';

        Test.startTest();
        FlowValidarDocumento.Output result = FlowValidarDocumento.validarDocumento(new List<FlowValidarDocumento.Input>{inp})[0];
        Test.stopTest();

        System.AssertEquals(false, result.cpfValido);
        System.AssertEquals(true, result.cnpjValido);
    }
}