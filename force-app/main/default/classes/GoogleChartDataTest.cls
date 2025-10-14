@isTest
public with sharing class GoogleChartDataTest 
{
    @IsTest
    static void constructorTest()
    {
        Test.startTest();
        GoogleChartData google = new GoogleChartData(500,500);
        Test.stopTest();
        System.assertEquals(500, google.arm, 'Algo deu errado - GoogleChartData.arm');
        System.assertEquals(500, google.weight, 'Algo deu errado - GoogleChartData.arm');
    }
}