export function logError(metodo, error) {
    if (error) {
        console.error('metodo => ', metodo); 
        console.error('erro => ', error);  
        if(error.body){
            console.error('error.body.exceptionType => ', error.body.exceptionType);
            console.error('error.body.message => ', error.body.message);
            console.error('error.body.stackTrace => ', error.body.stackTrace);
        }else{
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
        }
    }
}