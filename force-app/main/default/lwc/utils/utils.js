export default class Utils {
  //Z
  dateFromString(str) {
    if (str) {
      if (str instanceof Date) return str;
      let a = str.split(/[^0-9]/).map((s) => parseInt(s, 10));
      let date = new Date(
        a[0],
        a[1] - 1 || 0,
        a[2] || 1,
        a[3] || 0,
        a[4] || 0,
        a[5] || 0,
        a[6] || 0
      );
      if (str.includes("Z") || str.includes("+")) {
        date = new Date(date.getTime() - date.getTimezoneOffset() * 60000);
      }
      return date;
    }
    throw "n n n n";
  }
}