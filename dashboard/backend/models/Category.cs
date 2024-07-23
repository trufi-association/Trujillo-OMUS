using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Category
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public int? ParentId { get; set; }

    public required string CategoryName { get; set; }
    public required bool hasVictim { get; set; }
    public required bool hasDateTime { get; set; }

}
